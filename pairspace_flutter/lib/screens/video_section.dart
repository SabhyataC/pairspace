import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:pairspace_client/pairspace_client.dart';
import 'package:web/web.dart' as web;

import '../client.dart';

class _Peer {
  _Peer(this.id, this.pc, this.thumb, this.stage);

  final int id;
  final RTCPeerConnection pc;
  final RTCVideoRenderer thumb;
  final RTCVideoRenderer stage;
  final pendingCandidates = <RTCIceCandidate>[];
  bool remoteDescriptionSet = false;
  bool hasStream = false;
  bool connected = false;

  set stream(MediaStream? s) {
    thumb.srcObject = s;
    stage.srcObject = s;
  }
}

class VideoParts {
  const VideoParts({
    required this.stage,
    required this.controls,
    required this.tileFor,
    required this.pinnedId,
    required this.pin,
  });

  final Widget stage;
  final Widget controls;
  final Widget Function(int participantId) tileFor;
  final int? pinnedId;
  final void Function(int participantId) pin;
}

class VideoSection extends StatefulWidget {
  const VideoSection({
    super.key,
    required this.roomId,
    required this.participantId,
    required this.names,
    required this.builder,
  });

  final int roomId;
  final int participantId;
  final Map<int, String> names;
  final Widget Function(BuildContext context, VideoParts parts) builder;

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  final _localThumb = RTCVideoRenderer();
  final _localStage = RTCVideoRenderer();
  final _peers = <int, _Peer>{};
  final _earlyCandidates = <int, List<RTCIceCandidate>>{};

  MediaStream? _localStream;
  StreamController<SignalMessage>? _outgoing;
  StreamSubscription<SignalMessage>? _incomingSub;
  Timer? _visibilityTimer;
  Future<void> _signalQueue = Future.value();
  bool _disposed = false;

  int? _pinnedId;
  bool _micOn = true;
  bool _camOn = true;
  bool _hasCamera = false;
  bool _hasMic = false;
  String? _error;

  Map<String, dynamic> _iceConfig = {
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

  Future<void> _loadIceServers() async {
    try {
      final raw = await client.videoSignal.iceServers();
      final list = jsonDecode(raw) as List;
      _iceConfig = {'iceServers': list};
      _debug('ICE servers loaded: ${list.length} entries');
    } catch (e) {
      _debug('Using default STUN only: $e');
    }
  }

  Future<MediaStream?> _acquireLocalMedia() async {
    final attempts = <(Map<String, dynamic>, bool, bool)>[
      (
        {
          'audio': true,
          'video': {'facingMode': 'user'},
        },
        true,
        true,
      ),
      ({'audio': true, 'video': false}, true, false),
      (
        {
          'audio': false,
          'video': {'facingMode': 'user'},
        },
        false,
        true,
      ),
    ];
    for (final (constraints, mic, cam) in attempts) {
      try {
        final stream = await navigator.mediaDevices.getUserMedia(constraints);
        _hasMic = mic;
        _hasCamera = cam;
        return stream;
      } catch (e) {
        _debug('getUserMedia $constraints failed: $e');
      }
    }
    return null;
  }

  Future<void> _start() async {
    try {
      _debug('Participant ID: ${widget.participantId}, Room: ${widget.roomId}');

      await _localThumb.initialize();
      await _localStage.initialize();
      await _loadIceServers();

      _localStream = await _acquireLocalMedia();
      _localThumb.srcObject = _localStream;
      _localStage.srcObject = _localStream;
      if (_disposed) return;
      setState(() {
        _micOn = _hasMic;
        _camOn = _hasCamera;
      });
      _debug('Local media: mic=$_hasMic, camera=$_hasCamera');

      _visibilityTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (!mounted) return;
        _forceVideoVisible();
      });

      final outgoing = StreamController<SignalMessage>();
      _outgoing = outgoing;

      final incoming = client.videoSignal.signalStream(
        widget.roomId,
        widget.participantId,
        outgoing.stream,
      );
      _incomingSub = incoming.listen(
        (msg) {
          _signalQueue = _signalQueue.then((_) => _handleSignal(msg));
        },
        onError: (e) {
          _debug('SIGNALING ERROR: $e');
          if (!mounted) return;
          setState(() => _error = 'Video connection error: $e');
        },
      );

      _send('ready');
      _debug('READY signal sent');
    } catch (e, stackTrace) {
      _debug('START ERROR: $e');
      _debug('$stackTrace');
      if (!mounted) return;
      setState(() => _error = 'Could not start video: $e');
    }
  }

  void _send(
    String type, {
    int? target,
    String? sdp,
    RTCIceCandidate? candidate,
  }) {
    _outgoing?.add(
      SignalMessage(
        senderParticipantId: widget.participantId,
        targetParticipantId: target,
        type: type,
        sdp: sdp,
        candidate: candidate?.candidate,
        sdpMid: candidate?.sdpMid,
        sdpMLineIndex: candidate?.sdpMLineIndex,
      ),
    );
  }

  Future<_Peer> _createPeer(int id) async {
    final pc = await createPeerConnection(_iceConfig);
    final thumb = RTCVideoRenderer();
    final stage = RTCVideoRenderer();
    await thumb.initialize();
    await stage.initialize();
    final peer = _Peer(id, pc, thumb, stage);

    final local = _localStream;
    for (final kind in [
      RTCRtpMediaType.RTCRtpMediaTypeAudio,
      RTCRtpMediaType.RTCRtpMediaTypeVideo,
    ]) {
      final isAudio = kind == RTCRtpMediaType.RTCRtpMediaTypeAudio;
      final tracks = isAudio
          ? local?.getAudioTracks()
          : local?.getVideoTracks();

      if (local != null && tracks != null && tracks.isNotEmpty) {
        await pc.addTrack(tracks.first, local);
      } else {
        await pc.addTransceiver(
          kind: kind,
          init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
        );
      }
    }

    pc.onTrack = (event) {
      if (event.streams.isEmpty || _peers[id] != peer) return;
      peer.stream = event.streams.first;
      if (mounted) setState(() => peer.hasStream = true);
      _forceVideoVisible();
    };

    pc.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      _send('candidate', target: id, candidate: candidate);
    };

    pc.onConnectionState = (state) {
      _debug('PEER $id CONNECTION STATE: $state');
      if (_peers[id] != peer) return;
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        if (mounted) setState(() => peer.connected = true);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _dropPeer(id);
      }
    };

    final old = _peers[id];
    _peers[id] = peer;
    if (old != null) await _disposePeer(old);
    if (mounted) setState(() {});

    final early = _earlyCandidates.remove(id);
    if (early != null) peer.pendingCandidates.addAll(early);
    return peer;
  }

  Future<void> _disposePeer(_Peer peer) async {
    try {
      peer.stream = null;
      await peer.pc.close();
      await peer.thumb.dispose();
      await peer.stage.dispose();
    } catch (e) {
      _debug('Dispose peer ${peer.id} error: $e');
    }
  }

  void _dropPeer(int id) {
    final peer = _peers.remove(id);
    _earlyCandidates.remove(id);
    if (peer == null) return;
    _disposePeer(peer);
    if (mounted) setState(() {});
  }

  Future<void> _offerTo(int id) async {
    final peer = await _createPeer(id);
    final offer = await peer.pc.createOffer();
    await peer.pc.setLocalDescription(offer);
    _send('offer', target: id, sdp: offer.sdp);
    _debug('OFFER SENT to $id');
  }

  Future<void> _handleSignal(SignalMessage msg) async {
    if (_disposed) return;
    final from = msg.senderParticipantId;
    _debug('SIGNAL RECEIVED: type=${msg.type}, sender=$from');

    try {
      switch (msg.type) {
        case 'ready':
          await _offerTo(from);
          break;

        case 'offer':
          final existing = _peers[from];
          if (existing != null &&
              existing.pc.signalingState ==
                  RTCSignalingState.RTCSignalingStateHaveLocalOffer &&
              widget.participantId < from) {
            _debug('Offer glare with $from: keeping my offer');
            return;
          }
          final peer = await _createPeer(from);
          await peer.pc.setRemoteDescription(
            RTCSessionDescription(msg.sdp, 'offer'),
          );
          peer.remoteDescriptionSet = true;
          await _flushPendingCandidates(peer);

          final answer = await peer.pc.createAnswer();
          await peer.pc.setLocalDescription(answer);
          _send('answer', target: from, sdp: answer.sdp);
          _debug('ANSWER SENT to $from');
          break;

        case 'answer':
          final peer = _peers[from];
          if (peer == null ||
              peer.pc.signalingState !=
                  RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
            return;
          }
          await peer.pc.setRemoteDescription(
            RTCSessionDescription(msg.sdp, 'answer'),
          );
          peer.remoteDescriptionSet = true;
          await _flushPendingCandidates(peer);
          break;

        case 'candidate':
          if (msg.candidate == null) return;
          final candidate = RTCIceCandidate(
            msg.candidate,
            msg.sdpMid,
            msg.sdpMLineIndex,
          );
          final peer = _peers[from];
          if (peer == null) {
            _earlyCandidates.putIfAbsent(from, () => []).add(candidate);
          } else if (peer.remoteDescriptionSet) {
            await peer.pc.addCandidate(candidate);
          } else {
            peer.pendingCandidates.add(candidate);
          }
          break;

        case 'leave':
          _dropPeer(from);
          break;

        default:
          _debug('Unknown signal type: ${msg.type}');
      }
    } catch (e, stackTrace) {
      _debug('SIGNAL HANDLING ERROR (${msg.type}): $e');
      _debug('$stackTrace');
    }
  }

  Future<void> _flushPendingCandidates(_Peer peer) async {
    for (final c in peer.pendingCandidates) {
      await peer.pc.addCandidate(c);
    }
    peer.pendingCandidates.clear();
  }

  void _forceVideoVisible() {
    final videos = web.document.querySelectorAll('flt-platform-view video');
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

  void _pin(int id) {
    if (id == widget.participantId) return;
    setState(() => _pinnedId = _pinnedId == id ? null : id);
  }

  int? _effectivePinnedId() {
    final pinned = _pinnedId;
    if (pinned != null && _peers.containsKey(pinned)) return pinned;
    if (_peers.isEmpty) return null;
    return (_peers.keys.toList()..sort()).first;
  }

  @override
  void dispose() {
    _disposed = true;
    _visibilityTimer?.cancel();
    _send('leave');
    final outgoing = _outgoing;
    Future.delayed(const Duration(milliseconds: 300), () => outgoing?.close());
    _incomingSub?.cancel();
    _localStream?.getTracks().forEach((t) => t.stop());
    for (final peer in _peers.values) {
      _disposePeer(peer);
    }
    _peers.clear();
    _localThumb.dispose();
    _localStage.dispose();
    super.dispose();
  }

  String _nameOf(int id) => widget.names[id] ?? 'Participant';

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      VideoParts(
        stage: _buildStage(),
        controls: _buildControls(),
        tileFor: _buildListTile,
        pinnedId: _effectivePinnedId(),
        pin: _pin,
      ),
    );
  }

  Widget _buildStage() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          _error!,
          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
        ),
      );
    }

    final pinnedId = _effectivePinnedId();
    final peer = pinnedId == null ? null : _peers[pinnedId];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = ((constraints.maxWidth - 8) / 2).clamp(120.0, 280.0);
        final height = width * 9 / 16;
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: width,
                height: height,
                child: _videoTile(
                  _localStage,
                  label: 'You',
                  overlayText: _hasCamera && _camOn ? null : 'Camera off',
                  mirror: true,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: width,
                height: height,
                child: peer == null
                    ? _videoTile(
                        null,
                        label: '',
                        overlayText: 'Waiting for others to join…',
                      )
                    : _videoTile(
                        peer.stage,
                        label: '${_nameOf(peer.id)} (pinned)',
                        overlayText: _peerOverlay(peer),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _peerOverlay(_Peer peer) {
    if (peer.hasStream) return null;
    return peer.connected ? 'No camera' : 'Connecting…';
  }

  Widget _buildListTile(int participantId) {
    final isSelf = participantId == widget.participantId;
    if (isSelf) {
      return _videoTile(
        _localThumb,
        label: '',
        overlayText: _hasCamera && _camOn ? null : 'Camera off',
        mirror: true,
      );
    }
    final peer = _peers[participantId];
    if (peer == null) {
      return _videoTile(null, label: '', overlayText: 'Connecting…');
    }
    return _videoTile(peer.thumb, label: '', overlayText: _peerOverlay(peer));
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _micOn ? Icons.mic : Icons.mic_off,
              color: _micOn ? Colors.white : const Color(0xFFEF4444),
              size: 20,
            ),
            onPressed: _hasMic ? _toggleMic : null,
            tooltip: _hasMic
                ? (_micOn ? 'Mute' : 'Unmute')
                : 'No microphone found',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              _camOn ? Icons.videocam : Icons.videocam_off,
              color: _camOn ? Colors.white : const Color(0xFFEF4444),
              size: 20,
            ),
            onPressed: _hasCamera ? _toggleCam : null,
            tooltip: _hasCamera
                ? (_camOn ? 'Turn off camera' : 'Turn on camera')
                : 'No camera found',
          ),
        ],
      ),
    );
  }

  Widget _videoTile(
    RTCVideoRenderer? renderer, {
    required String label,
    String? overlayText,
    bool mirror = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (renderer != null)
            RTCVideoView(
              renderer,
              mirror: mirror,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          if (overlayText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                overlayText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (label.isNotEmpty)
            Positioned(
              left: 6,
              bottom: 4,
              right: 6,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
