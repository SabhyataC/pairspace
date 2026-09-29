BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "participant" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "participant" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "authUserId" uuid NOT NULL,
    "role" text NOT NULL,
    "status" text NOT NULL,
    "displayName" text NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "participant_room_user_idx" ON "participant" USING btree ("roomId", "authUserId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "participant"
    ADD CONSTRAINT "participant_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR pairspace
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pairspace', '20260929054927593', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260929054927593', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
