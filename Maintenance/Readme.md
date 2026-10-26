# Maintenance mode — install, operate, integrate

Classic ASP.NET WebForms (.NET Framework 4.8), IIS. No database, no extra service, no CDN,
no JavaScript library. Everything is plain HTML/CSS/JS plus two `web.config` settings.

---

## 1. How it works

Two independent switches. Neither depends on the other, and that is deliberate.

| Switch | Controls | Works while the app is offline? |
|---|---|---|
| `app_offline.htm` in the **application root** | the hard block: ASP.NET answers **503 + this page** for every managed request | it *is* the block |
| `maintenance\status.txt` | the user experience: banner, popup, auto-reopen | **yes** — IIS still serves static files |

Because the status file is only cosmetic, a stale value can never re-open a blocked site, and a
missing file can never let anyone past `app_offline.htm`.

| Status | Meaning | Open pages | Cold visit | Poll |
|---|---|---|---|---|
| `RUNNING` | normal | nothing | normal app | 4 s |
| `WARNING` | update about to start | red banner across the top, app still usable | normal app | 1 s |
| `MAINTENANCE` | deployment running | full-screen popup with the offline page, blurred app behind | 503 + offline page | 1 s |

Recovery: the offline page reloads itself after two consecutive `RUNNING` reads. Open tabs
reload too, and a reload is skipped if the user submitted a form in the previous 5 seconds.

---

## 2. Files

| File | Role | Goes to the server? |
|---|---|---|
| `Maintenance/app_offline.htm` | the maintenance page. Self-contained: inline CSS/JS, no images, no external requests. | **Yes** — application root, exact name `app_offline.htm` |
| `Maintenance/status.template.txt` | format reference (`RUNNING`) | No |
| `Maintenance/local-maintenance.ps1` | one-command switch for local testing | No |
| `GL/wwwroot/lib/theme/maintenance-watch.js` | watcher: banner, popup, auto-reload | Yes — ships with the app |
| `GL/wwwroot/lib/theme/maintenance-watch.css` | banner + popup frame | Yes — ships with the app |
| `GL/Site.Master`, `GL/SiteNoMenu.Master` | load the watcher on every page | Yes |
| `GL/Web.config` | 2 settings (see §3.4) | Yes |
| `GL/GL.csproj` | registers the two theme files | build only |

### Runtime layout

```
<application root>                  e.g. C:\inetpub\wwwroot\HMS\AsSiraatUAT
├── Web.config
├── bin\
├── app_offline.htm                 exists ONLY while maintenance is active
├── maintenance\
│   └── status.txt                  RUNNING | WARNING | MAINTENANCE  (always present)
└── wwwroot\lib\theme\maintenance-watch.{js,css}
```

Rules that must not be broken:

- `app_offline.htm` only works **in the application root**, spelled exactly like that. `.html`
  does nothing.
- `status.txt` must **never** be inside the deployment ZIP. It is runtime state; a packaged copy
  would re-open the site at the wrong moment.
- `app_offline.htm` must never be in the ZIP either — Jenkins copies it explicitly.
- The status file must stay a **static** file. Do not enable
  `runAllManagedModulesForAllRequests`; if you ever must, add
  `<location path="maintenance"><allow users="*"/></location>` to `Web.config`.

---

## 3. Install in another project (checklist)

Copy these four things, then apply three config edits.

### 3.1 Copy the watcher

```
GL/wwwroot/lib/theme/maintenance-watch.js
GL/wwwroot/lib/theme/maintenance-watch.css
```

### 3.2 Register them in the project

In `GL.csproj`, next to the other theme files:

```xml
<Content Include="wwwroot\lib\theme\maintenance-watch.css" />
<Content Include="wwwroot\lib\theme\maintenance-watch.js" />
```

### 3.3 Load the watcher in both master pages

`GL/Site.Master`, immediately before `</head>` (`Ver()` already exists there):

```aspx
<link href="<%= Page.ResolveClientUrl("~/wwwroot/lib/theme/maintenance-watch.css") %>?v=<%= Ver("~/wwwroot/lib/theme/maintenance-watch.css") %>" rel="stylesheet" type="text/css" />
<script type="text/javascript">window.HMSMaintenanceUrl = '<%= Page.ResolveUrl("~/maintenance/status.txt") %>';</script>
<script src="<%= Page.ResolveClientUrl("~/wwwroot/lib/theme/maintenance-watch.js") %>?v=<%= Ver("~/wwwroot/lib/theme/maintenance-watch.js") %>" type="text/javascript"></script>
```

`GL/SiteNoMenu.Master` (login shell, no `Ver()`), just before `</head>`:

```aspx
<link href="<%= Page.ResolveUrl("~/wwwroot/lib/theme/maintenance-watch.css") %>" rel="stylesheet" type="text/css" />
<script type="text/javascript">window.HMSMaintenanceUrl = '<%= Page.ResolveUrl("~/maintenance/status.txt") %>';</script>
<script src="<%= Page.ResolveUrl("~/wwwroot/lib/theme/maintenance-watch.js") %>" type="text/javascript"></script>
```

### 3.4 Two `GL/Web.config` changes

```xml
<system.webServer>
  <!-- 1. Show the app_offline body. "Replace" swaps it for IIS's 27-byte 503 page. -->
  <httpErrors errorMode="Custom" existingResponse="Auto">
    ...
  </httpErrors>

  <!-- 2. Never cache. The 503 carries Retry-After: 3600, so a cached copy can hide the
          new state for an hour. -->
  <httpProtocol>
    <customHeaders>
      <add name="Cache-Control" value="no-store, no-cache, must-revalidate" />
    </customHeaders>
  </httpProtocol>
</system.webServer>
```

Why `Auto` and not the alternatives: a 503 `File` mapping is site-root relative and breaks in a
sub-application; an `ExecuteURL` mapping can return **200** with the maintenance body (a health
check would read that as success); `PassThrough` disables the existing `NotFound.aspx` 404 page.

### 3.5 Seed the runtime folder once

```powershell
New-Item -ItemType Directory "C:\inetpub\wwwroot\HMS\AsSiraatUAT\maintenance" -Force | Out-Null
Set-Content "C:\inetpub\wwwroot\HMS\AsSiraatUAT\maintenance\status.txt" "RUNNING" -Encoding ASCII -NoNewline
```

### 3.6 Verify

1. Open `Login.aspx?x=1` — normal app.
2. Copy `app_offline.htm` to the application root — the page appears with **503**.
   If IIS's own "service unavailable" text appears instead, §3.4-1 is missing.
3. Still offline, request `/maintenance/status.txt` — must return **200**.
4. Delete `app_offline.htm` — normal app again, no restart.

---

## 4. Daily use

### On the server

```powershell
$APP = "C:\inetpub\wwwroot\HMS\AsSiraatUAT"
$MNT = Join-Path $APP "maintenance"

function Set-HmsStatus([string]$value) {
    if ($value -notin @("RUNNING", "WARNING", "MAINTENANCE")) { throw "Bad status: $value" }
    $tmp = Join-Path $MNT "status.txt.tmp"
    Set-Content $tmp -Value $value -Encoding ASCII -NoNewline   # atomic: never half-written
    Move-Item $tmp (Join-Path $MNT "status.txt") -Force
}

# starting
Copy-Item "\\build\Maintenance\app_offline.htm" (Join-Path $APP "app_offline.htm") -Force
Set-HmsStatus "MAINTENANCE"

# finishing (only after the health check)
Remove-Item (Join-Path $APP "app_offline.htm") -Force
Set-HmsStatus "RUNNING"
```

**Order matters.** File first, status second — going both ways. An open tab reads the status and
immediately loads `app_offline.htm` in the popup; if the file were not there yet, the popup would
show an error page for a moment.

### Locally

```powershell
.\Maintenance\local-maintenance.ps1 WARNING
.\Maintenance\local-maintenance.ps1 MAINTENANCE
.\Maintenance\local-maintenance.ps1 RUNNING
```

Operates on `GL\` (the local IIS Express root, `http://localhost:28402/`). It applies the same
file-first ordering.

---

## 5. Jenkins integration (example)

Existing stages stay as they are; three steps are inserted and one gate is added after the deploy.

```
1. approval                     unchanged
2. package                      unchanged
3.  NEW  WARNING                Set-HmsStatus WARNING ; Start-Sleep -Seconds 180
4.  NEW  MAINTENANCE            copy app_offline.htm ; Set-HmsStatus MAINTENANCE
5. backup (WinRAR)              unchanged - now runs with the site quiet, bin\ unlocked
6. deploy (Expand-Archive)      unchanged - additive, does not wipe
7.  NEW  verify                 remove app_offline.htm ; poll Login.aspx until 200
8.  NEW  RUNNING                Set-HmsStatus RUNNING   (only if 7 passed)
9. notify                       unchanged, plus a failure notification
```

Health gate:

```powershell
$APP = "C:\inetpub\wwwroot\HMS\AsSiraatUAT"
$URL = "http://<host>/HMS/AsSiraatUAT/Login.aspx"

Remove-Item (Join-Path $APP "app_offline.htm") -Force      # app must be up to answer
$ok = $false
for ($i = 0; $i -lt 12; $i++) {
    try {
        $r = Invoke-WebRequest $URL -UseBasicParsing -TimeoutSec 10
        if ($r.StatusCode -eq 200) { $ok = $true; break }
    } catch { }
    Start-Sleep -Seconds 5
}
if (-not $ok) {
    Copy-Item "\\build\Maintenance\app_offline.htm" (Join-Path $APP "app_offline.htm") -Force
    throw "Deployment failed verification - the site is left CLOSED on purpose."
}
Set-HmsStatus "RUNNING"
```

Failure rules:

- Before `app_offline.htm` exists → set `RUNNING`, notify, stop.
- After it exists → **never** write `RUNNING` and **never** delete the file automatically. Restore
  the backup, verify, and only then set `RUNNING`. A closed site beats a half-deployed one.
- Wrap the pipeline in `post { failure { ... } }` so a cancelled build cannot leave the site
  unlocked with half-copied files.

Packaging note: the ZIP must **not** contain `app_offline.htm` or `maintenance\status.txt`.

---

## 6. Customising

| What | Where |
|---|---|
| Colours | `Maintenance/app_offline.htm`, `:root` → `--accent`, `--accent-dark`, `--accent-light`, `--accent-soft`, `--accent-border` (one place) |
| Texts | the `<h1>`, the lead paragraph and the note line in the same file |
| Remove the mini-game | delete the `<section aria-labelledby="game-title">` block and its script |
| Banner text | `GL/wwwroot/lib/theme/maintenance-watch.js`, `showBanner()` |
| Poll speed | constants at the top of both scripts (`4000`, `1000`, `15000`) |

The page is a single file with no external requests; if you edit it, keep it that way.

---

## 7. Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| IIS's "The service is unavailable." instead of the page | `existingResponse="Replace"` | §3.4-1 |
| Old page keeps appearing after an update | browser cached the old 503 | Ctrl+Shift+R, or a fresh URL `?x=1`; the `Cache-Control` header prevents it from now on |
| Banner appears, popup does not | `app_offline.htm` missing when `MAINTENANCE` was written | copy the file **before** the status |
| Nothing happens at all | status file in the wrong place | must be `<app root>\maintenance\status.txt` |
| Status file returns 404 while online | folder/file not seeded | §3.5 |
| Status file briefly returns 503 | the AppDomain is unloading (~10 s after the file appears) | normal — polling retries |
| Everyone is logged out after a deploy | `machineKey AutoGenerate`, sessions `InProc` | expected; the `WARNING` phase exists to let people save work |
| Popup has no blur | browser older than Chrome 76 / Firefox 103 | degrades to a dark dim; still usable |

---

## 8. Test checklist

Proven locally on IIS Express; repeat on the demo server before production.

| # | Test | Expected |
|---|---|---|
| 1 | `app_offline.htm` in the app root, open `Login.aspx` | 503 + this page, not IIS's error |
| 2 | deep page (`/Modules/…`) while offline | same page, 503 |
| 3 | `/maintenance/status.txt` while offline | 200, current token |
| 4 | `WARNING` with the app online | red banner within ~1 s, forms still submit |
| 5 | `MAINTENANCE` in an open tab | popup appears without touching the browser |
| 6 | any link / Back / form submit while offline | the maintenance page again |
| 7 | `RUNNING` | popup/page returns to the app by itself |
| 8 | deploy killed halfway | site stays closed, no `RUNNING` written |
| 9 | rollback + verify | only then `RUNNING` |
| 10 | 50 open tabs polling | negligible load, no 404 storm |

Verified values on the local run: page **36,863 bytes**, 503 on the app, 200 for
`app_offline.htm`, 200 for `status.txt`, 200 after `RUNNING`.

---

## 9. Limits

- The application root is an **assumption** until confirmed on the demo server: it must be the
  folder that directly contains `Web.config` and `bin\`.
- The health gate proves ASP.NET starts and the page renders. It does not prove database
  connectivity or that every page compiles.
- A deploy always logs users out (`machineKey AutoGenerate`, `InProc` sessions).
- Long-running requests (Crystal reports) can be cut when the AppDomain unloads; the `WARNING`
  phase is the only protection.
- Nothing here was deployed or tested on a server. Only the local IIS Express behaviour above is
  proven.
