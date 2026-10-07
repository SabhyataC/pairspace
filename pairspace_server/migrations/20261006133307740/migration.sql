BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "stroke" ADD COLUMN "kind" text NOT NULL DEFAULT 'pen'::text;
ALTER TABLE "stroke" ADD COLUMN "text" text;
ALTER TABLE "stroke" ADD COLUMN "clientId" text NOT NULL DEFAULT ''::text;
ALTER TABLE "stroke" ADD COLUMN "isDeleted" boolean NOT NULL DEFAULT false;
CREATE INDEX "stroke_client_idx" ON "stroke" USING btree ("roomId", "clientId");

--
-- MIGRATION VERSION FOR pairspace
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pairspace', '20261006133307740', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261006133307740', "timestamp" = now();

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
