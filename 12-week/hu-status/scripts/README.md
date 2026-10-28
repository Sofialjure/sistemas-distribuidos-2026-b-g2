# Week 12 optional activity: blue-green scripts

The scripts behind the blue-green release of `professional-management-api` in
[Session 1](../Optional%20Activity%20Week%2012%20-%20Session%201.md). They need the TeleMed IA
platform network (PostgreSQL, identity) and two images of the API built from
`deploy/Dockerfile`, tagged with their commit.

| File | What it does |
|---|---|
| [`start.sh`](start.sh) | Starts `pm-blue`, `pm-green`, a `pm-green-broken` that cannot reach its database, and the nginx front door `pm-lb` on `127.0.0.1:28090`. The health check is the readiness endpoint `:9081/actuator/health` |
| [`lb/default.conf`](lb/default.conf) | nginx server: proxies to the active upstream and answers `X-Served-By` with the color and commit |
| [`lb/blue.inc`](lb/blue.inc), [`lb/green.inc`](lb/green.inc) | One upstream each; switching is copying one of them over `lb/active.inc` and a graceful `nginx -s reload` |
| [`rollout.sh`](rollout.sh) | Sends one authenticated read every 50 ms, switches to green, rehearses the rollback to blue, and counts status codes and serving color |
| [`gate-test.sh`](gate-test.sh) | Tries to switch to `pm-green-broken` and shows that the health gate refuses it and traffic stays where it was |

```bash
./start.sh <network> pm.env jwt.pem professional-management-api:<blue commit> professional-management-api:<green commit>
./gate-test.sh
mkdir -p run && ./rollout.sh admin.token run
```

`pm.env`, `jwt.pem` and `admin.token` are local files with configuration, the public key and
an administrator token: they are not in the repository. `lb/active.inc` is written at run time.
Clean up with `docker rm -f pm-lb pm-blue pm-green pm-green-broken`.
