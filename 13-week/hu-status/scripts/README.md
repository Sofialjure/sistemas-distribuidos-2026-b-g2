# Week 13 optional activities: security scripts

The scripts behind the live probes of
[Session 1](../Optional%20Activity%20Week%2013%20-%20Session%201.md) and the security gates of
[Session 2](../Optional%20Activity%20Week%2013%20-%20Session%202.md).

| Script | What it does | Used in |
|---|---|---|
| [`mint-tokens.sh`](mint-tokens.sh) | Writes `probe.env`: patient, professional and service tokens signed with the platform's development key, plus the negative cases (another key, expired, `alg: none`, payload edited to `ADMIN`) | Session 1 |
| [`probes.sh`](probes.sh) | The 20 probes: edge, calls that bypass the gateway, authorization per role, IDOR, input validation and error hygiene. Prints `PASS`/`FAIL` and a total | Session 1, section 5 |
| [`security-scans.sh`](security-scans.sh) | gitleaks over the full history of each repository (with a positive control) and trivy over the API image | Session 2, section 4 |

```bash
./mint-tokens.sh <dev private key> admin.token <professional id> <document id> <patient id>
# the probes run inside the platform network, like a compromised neighbour would
docker run --rm --network <network> --env-file probe.env -v "$PWD:/w:ro" \
  --entrypoint sh curlimages/curl:8.10.1 /w/probes.sh
./security-scans.sh professional-management-api:<commit> <repository folders>
```

`probe.env`, `other.pem` and `admin.token` hold live tokens and keys: they are generated
locally and are not in the repository. Use only the development key of a local platform.
