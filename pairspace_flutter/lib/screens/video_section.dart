import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:pairspace_client/pairspace_client.dart';
import 'package:web/web.dart' as web;

import '../client.dart';

class VideoSection extends StatefulWidget {
  const VideoSection({
    super.key,
    required this.roomId,
    required this.participantId,
    required this.isCaller,
  });

  final int roomId;
  final int participantId;
  final bool isCaller;

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  StreamController<SignalMessage>? _outgoing;
  StreamSubscription<SignalMessage>? _incomingSub;
  Timer? _visibilityTimer;

  final _pendingCandidates = <RTCIceCandidate>[];
  bool _remoteDescriptionSet = false;
  bool _offerSent = false;

  bool _micOn = true;
  bool _camOn = true;
  bool _connecting = true;
  String? _error;

  static const _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  void _debug(String message) => debugPrint('[WebRTC] $message');

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      _debug(
        'Role: ${widget.isCaller ? "Interviewer / Caller" : "Candidate / Receiver"}',
      );
      _debug(
        'Participant ID: ${widget.participantId}, Room ID: ${widget.roomId}',
      );

      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });
      _localRenderer.srcObject = _localStream;
      _debug(
        'Local media acquired: ${_localStream!.getTracks().length} tracks',
      );

      // Keep forcing the <video> elements visible for the lifetime of this
      // widget. flutter_webrtc's web renderer sometimes leaves video
      // elements at opacity:0 — this happens on first connect, and again
      // whenever the renderer is rebuilt (e.g. after a setState from the
      // mic/cam toggle buttons).
      _visibilityTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (!mounted) return;
        _forceVideoVisible();
      });

      _pc = await createPeerConnection(_iceServers);
      _debug('Peer connection created');

      for (final track in _localStream!.getTracks()) {
        await _pc!.addTrack(track, _localStream!);
      }

      _pc!.onTrack = (event) {
        _debug(
          'REMOTE TRACK RECEIVED: kind=${event.track.kind}, streams=${event.streams.length}',
        );
        if (event.streams.isNotEmpty) {
          _remoteRenderer.srcObject = event.streams.first;
          if (mounted) setState(() => _connecting = false);
          _forceVideoVisible();
        }
      };

      _pc!.onIceConnectionState = (state) {
        _debug('ICE CONNECTION STATE: $state');
      };

      _pc!.onConnectionState = (state) {
        _debug('PEER CONNECTION STATE: $state');
      };

      final outgoing = StreamController<SignalMessage>();
      _outgoing = outgoing;

      _pc!.onIceCandidate = (candidate) {
        if (candidate.candidate == null) return;
        outgoing.add(
          SignalMessage(
            senderParticipantId: widget.participantId,
            type: 'candidate',
            candidate: candidate.candidate,
            sdpMid: candidate.sdpMid,
            sdpMLineIndex: candidate.sdpMLineIndex,
          ),
        );
      };

      final incoming = client.videoSignal.signalStream(
        widget.roomId,
        widget.participantId,
        outgoing.stream,
      );
      _incomingSub = incoming.listen(
        _handleSignal,
        onError: (e) {
          _debug('SIGNALING ERROR: $e');
          if (!mounted) return;
          setState(() => _error = 'Video connection error: $e');
        },
      );

      // Announce presence. The caller only sends its offer after hearing
      // the other side's "ready" — avoids sending an offer before anyone
      // is listening.
      outgoing.add(
        SignalMessage(
          senderParticipantId: widget.participantId,
          type: 'ready',
        ),
      );
      _debug('READY signal sent');
    } catch (e, stackTrace) {
      _debug('START ERROR: $e');
      _debug('$stackTrace');
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _error = 'Could not start video: $e';
      });
    }
  }

  Future<void> _sendOfferIfNeeded() async {
    if (!widget.isCaller || _offerSent || _pc == null) {
      _debug(
        'Offer skipped | isCaller=${widget.isCaller}, offerSent=$_offerSent',
      );
      return;
    }
    _offerSent = true;

    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    _outgoing?.add(
      SignalMessage(
        senderParticipantId: widget.participantId,
        type: 'offer',
        sdp: offer.sdp,
      ),
    );
    _debug('OFFER SENT');
  }

  Future<void> _handleSignal(SignalMessage msg) async {
    final pc = _pc;
    if (pc == null) {
      _debug('ERROR: Received ${msg.type} but peer connection is null');
      return;
    }

    _debug(
      'SIGNAL RECEIVED: type=${msg.type}, sender=${msg.senderParticipantId}',
    );

    try {
      switch (msg.type) {
        case 'ready':
          await _sendOfferIfNeeded();
          break;

        case 'offer':
          await pc.setRemoteDescription(
            RTCSessionDescription(msg.sdp, 'offer'),
          );
          _remoteDescriptionSet = true;
          await _flushPendingCandidates();

          final answer = await pc.createAnswer();
          await pc.setLocalDescription(answer);
          _outgoing?.add(
            SignalMessage(
              senderParticipantId: widget.participantId,
              type: 'answer',
              sdp: answer.sdp,
            ),
          );
          _debug('ANSWER SENT');
          break;

        case 'answer':
          await pc.setRemoteDescription(
            RTCSessionDescription(msg.sdp, 'answer'),
          );
          _remoteDescriptionSet = true;
          await _flushPendingCandidates();
          break;

        case 'candidate':
          if (msg.candidate == null) return;
          final candidate = RTCIceCandidate(
            msg.candidate,
            msg.sdpMid,
            msg.sdpMLineIndex,
          );
          if (_remoteDescriptionSet) {
            await pc.addCandidate(candidate);
          } else {
            _pendingCandidates.add(candidate);
            _debug('Queued ICE candidate (remote description not set yet)');
          }
          break;

        default:
          _debug('Unknown signal type: ${msg.type}');
      }
    } catch (e, stackTrace) {
      _debug('SIGNAL HANDLING ERROR ($msg.type): $e');
      _debug('$stackTrace');
    }
  }

  Future<void> _flushPendingCandidates() async {
    for (final c in _pendingCandidates) {
      await _pc?.addCandidate(c);
    }
    _debug('Flushed ${_pendingCandidates.length} pending ICE candidates');
    _pendingCandidates.clear();
  }

  void _forceVideoVisible() {
    final videos = web.document.querySelectorAll('video');
    for (var i = 0; i < videos.length; i++) {
      final el = videos.item(i);
      if (el != null) {
        (el as web.HTMLElement).style.opacity = '1';
      }
    }
  }

  void _toggleMic() {
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !_micOn);
    setState(() => _micOn = !_micOn);
    _forceVideoVisible();
  }

  void _toggleCam() {
    _localStream?.getVideoTracks().forEach((t) => t.enabled = !_camOn);
    setState(() => _camOn = !_camOn);
    _forceVideoVisible();
  }

  @override
  void dispose() {
    _debug('DISPOSING VideoSection');
    _visibilityTimer?.cancel();
    _incomingSub?.cancel();
    _outgoing?.close();
    _localStream?.getTracks().forEach((t) => t.stop());
    _pc?.close();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 160,
          child: Row(
            children: [
              Expanded(
                child: _videoTile(
                  _remoteRenderer,
                  _connecting ? 'Waiting for video…' : null,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 120,
                child: _videoTile(_localRenderer, null, mirror: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_micOn ? Icons.mic : Icons.mic_off),
              onPressed: _toggleMic,
              tooltip: _micOn ? 'Mute' : 'Unmute',
            ),
            IconButton(
              icon: Icon(_camOn ? Icons.videocam : Icons.videocam_off),
              onPressed: _toggleCam,
              tooltip: _camOn ? 'Turn off camera' : 'Turn on camera',
            ),
          ],
        ),
      ],
    );
  }

  Widget _videoTile(
    RTCVideoRenderer renderer,
    String? overlayText, {
    bool mirror = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RTCVideoView(
            renderer,
            mirror: mirror,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          if (overlayText != null)
            Text(
              overlayText,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
