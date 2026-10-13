BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "code_edit" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "offset" bigint NOT NULL,
    "removed" bigint NOT NULL,
    "inserted" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "code_edit_room_idx" ON "code_edit" USING btree ("roomId", "createdAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "code_edit"
    ADD CONSTRAINT "code_edit_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR pairspace
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pairspace', '20261013133534600', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261013133534600', "timestamp" = now();

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
