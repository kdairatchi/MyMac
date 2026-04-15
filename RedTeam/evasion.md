# Evasion — Research Notes

This file is defensive-research-oriented. It names the techniques, explains what they do and why they work, and points to primary sources. It does not paste weaponised bypass code; every linked project contains working PoCs for authorised lab use and the defender-side detection guidance.

Everything here should be used only on engagements with explicit permission, and paired with a conversation with the blue team about detection coverage.

MITRE: https://attack.mitre.org/tactics/TA0005/ (Defense Evasion).

## Scope

This page is about Windows-side evasion — the dominant EDR surface. Linux evasion is simpler and mostly limited to binary packing / LD_PRELOAD / userland rootkits — covered in `persistence-linux.md`.

## AMSI (concept)

Antimalware Scan Interface — Microsoft-provided API (`AmsiScanBuffer`) that PowerShell, VBScript, JScript, Office VBA, WMI scripting, and .NET since 4.8 invoke to let AV scan in-memory content before execution.

Why offensive research targets AMSI:

- AMSI sits in-process; bypassing it is a local operation per process.
- Once a PowerShell session has a tampered `AmsiScanBuffer`, every subsequent `Invoke-Expression` skips scanning.

Defensive reality:

- Modern EDR watches for the canonical patch-byte patterns at `AmsiScanBuffer` and `amsi.dll!g_amsiContext` dereference.
- AMSI providers can log tamper attempts via Event ID 1116 / 1117 in Defender, and via EDR hooks.
- Applocker / WDAC + signed-only PowerShell + Constrained Language Mode collapses most AMSI bypasses because the bypass script can't run.

Primary reading:

- Matt Graeber's original PS patch research — https://cobbr.io/ScriptBlock-Warning-Event-Logging-Bypass.html
- Rastamouse AMSI catalogue — https://rastamouse.me/memory-patching-amsi-bypass/
- Microsoft AMSI docs — https://learn.microsoft.com/en-us/windows/win32/amsi/antimalware-scan-interface-portal
- Defender AMSI telemetry — https://learn.microsoft.com/en-us/defender-endpoint/amsi-on-mdav

Detection:

- `MpPreference.MAPSReporting` + cloud-delivered protection on.
- Sigma rules under `rules/windows/process_creation/proc_creation_win_susp_amsi_bypass*.yml`.
- Look for writes to `clr.dll`, `amsi.dll` `Protect` calls followed by `VirtualProtect` restore — hallmark pattern.

## ETW (concept)

Event Tracing for Windows — kernel + user telemetry. EDR vendors register ETW providers to receive process/thread/image-load/registry events.

Offensive research focus: disabling in-process ETW providers by patching `EtwEventWrite`, patching the TRACEHANDLE table, or unsubscribing the EDR's provider via `EnableTraceEx2`.

Why it matters: many user-mode EDR components rely entirely on ETW — a disabled provider means blind EDR for that process.

Primary reading:

- Outflank "Red Team Tactics: ETW patching" — https://outflank.nl/blog/2019/04/03/red-team-tactics-combining-direct-system-calls-and-srdi-to-bypass-av-edr/
- Palantir "Tampering with Windows Event Tracing" — https://palantir.com/blog/tampering-with-windows-event-tracing-background-offense-and-defense/
- modexp "ETW patching" — https://modexp.wordpress.com/2020/04/08/red-teams-etw/

Detection: monitor for `Microsoft-Windows-Threat-Intelligence` ETW provider drops; kernel-based EDR (callbacks registered at PsSetCreateProcessNotifyRoutineEx) is not blind to user-mode ETW patching.

## PPID spoofing (concept)

`STARTUPINFOEX` + `UpdateProcThreadAttribute(PROC_THREAD_ATTRIBUTE_PARENT_PROCESS)` lets a caller choose the parent of a child process, hiding the real launcher from downstream parent-child-chain analytics (e.g. winword → powershell alarms).

Primary reading:

- Didier Stevens "Parent PID Spoofing" — https://didiersteven.com — (search "parent PID spoofing")
- Red Canary blog "Better know a data source: Process creation" — https://redcanary.com/blog/process-creation/

Detection:

- Kernel ETW (`Microsoft-Windows-Kernel-Process`) records the *real* creating thread — spoofing only affects user-mode reported PPID. EDR that collects kernel process events sees both.
- Sysmon Event 1 with enhanced config surfaces `ParentImage` from kernel.

## Sleep obfuscation (concept)

C2 beacons spend most of their time sleeping. Idle beacons are detectable by memory scanners (Moneta, pe-sieve, Hunt-Sleeping-Beacons) that look for RX regions not backed by a signed image.

Research projects target: encrypt the beacon's code + heap while sleeping, switch to RW, decrypt on wake. Implementations vary: APC queuing, Timer queues (Ekko), Fiber-based (FOLIAGE), Waiting-Thread Hijacking (Cronos).

Primary references:

- Ekko — https://github.com/Cracked5pider/Ekko
- Cronos — https://github.com/Idov31/Cronos
- FOLIAGE — https://github.com/SecIdiot/FOLIAGE
- Hunt-Sleeping-Beacons — https://github.com/thefLink/Hunt-Sleeping-Beacons (detection)
- Moneta — https://github.com/forrest-orr/moneta (detection)
- pe-sieve — https://github.com/hasherezade/pe-sieve (detection)

Defensive: schedule scheduled memory sweeps with Moneta/pe-sieve; EDR with memory callbacks detects spray-to-RW-to-RX transitions.

## Direct / indirect syscalls (concept)

EDR typically hooks usermode APIs in `ntdll.dll` (NTAPI stubs) to inspect calls. Direct syscalls bypass userland ntdll entirely by re-implementing the syscall stub; indirect syscalls call the real ntdll stub after resolving the `syscall`/`sysenter` instruction dynamically.

Why still relevant in 2026: Microsoft added kernel-mode ETW-TI, Kernel Callbacks, and Hardware-enforced Stack Protection (HSP) — these reduce usermode-only evasion's value. Indirect syscalls remain effective against most mid-market EDR because they preserve the call-stack to ntdll.

Primary reading:

- ired.team "Direct syscalls" — https://www.ired.team/offensive-security/defense-evasion/using-syscalls-directly-from-visual-studio-to-bypass-avs-edrs
- Outflank "Combining direct syscalls and sRDI" — https://outflank.nl/blog/2019/04/03/red-team-tactics-combining-direct-system-calls-and-srdi-to-bypass-av-edr/
- SysWhispers3 — https://github.com/klezVirus/SysWhispers3
- Hell's Gate / Halo's Gate — am0nsec + smelly https://github.com/am0nsec/HellsGate

Detection:

- Kernel ETW-TI subscribing to `ThreadCreate`, `ImageLoad`.
- EDR drivers registering `PsSetCreateThreadNotifyRoutine`, `ObRegisterCallbacks`.
- Call-stack inspection — direct syscalls produce stacks with missing ntdll frames; modern EDR flags this pattern.

## Unhooking (concept)

Restore ntdll's clean `.text` section by reading a fresh copy from disk (or a suspended child process) and `memcpy`-ing over the hooked one. Common in open-source loaders.

Detection: `Microsoft-Windows-Threat-Intelligence` ETW Image Load events, callstack anomalies on subsequent syscalls. Projects: https://github.com/mgeeky/ThreadStackSpoofer.

## Reflective / module stomping loaders (concept)

- Reflective DLL injection (Stephen Fewer) — https://github.com/stephenfewer/ReflectiveDLLInjection
- sRDI (binary-to-shellcode) — https://github.com/monoxgas/sRDI
- Module stomping — overwrite a legitimately-loaded DLL's text with your payload so the memory region is backed by a valid image. Referenced by Outflank, https://outflank.nl/blog.
- Transacted Hollowing — https://github.com/hasherezade/transacted_hollowing

All generate image-load events; detection lies in entropy / code section hash vs on-disk.

## Command-line obfuscation (concept)

- Invoke-Obfuscation (PowerShell) — https://github.com/danielbohannon/Invoke-Obfuscation
- Invoke-DOSfuscation — https://github.com/danielbohannon/Invoke-DOSfuscation
- Bohannon's papers — https://www.fireeye.com/blog/threat-research/2017/12/invoke-obfuscation.html

Modern EDR uses AMSI + script block logging to see the deobfuscated script at execution time — obfuscation buys at-rest evasion, not behavioural.

## LOLBAS / living-off-the-land

Pre-installed signed binaries that can download, decode, or execute. Authoritative catalog: https://lolbas-project.github.io.

Common: `certutil.exe`, `bitsadmin.exe`, `mshta.exe`, `regsvr32.exe`, `rundll32.exe`, `msbuild.exe`, `installutil.exe`, `wmic.exe` (deprecated Win11+).

Linux counterpart GTFOBins — https://gtfobins.github.io.

Detection: each LOLBin's suspicious usage has specific Sigma rules. Parent-child + network destination is the signal.

## Summary: what actually works against mature EDR in 2026

- Indirect syscalls with call-stack spoofing
- Sleep obfuscation (Ekko-style) for long-dwell beacons
- Hardware breakpoints for hook bypass (without kernel callbacks firing)
- COM hijack for quiet persistence
- AMSI / ETW patching in short-lived processes
- Living-off-the-land with well-crafted parent lineage

What doesn't: stock msfvenom output, stock Cobalt Strike without malleable profile, straight PowerShell `IEX (New-Object Net.WebClient)...`, plaintext mimikatz from disk.

## Defensive posture recommendations

- WDAC in enforce mode
- PowerShell ConstrainedLanguage + Script Block Logging
- Defender for Endpoint with Tamper Protection + ASR rules
- EDR with kernel callbacks (ELAM driver)
- Sysmon with ThreatIntel config + central log pipeline
- Memory scanning (Moneta, pe-sieve) on triage
- Application allowlisting on privileged hosts
- Attack Surface Reduction: https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference

## References

- MITRE ATT&CK TA0005 — https://attack.mitre.org/tactics/TA0005/
- Unprotect Project (technique catalog, defender angle) — https://unprotect.it
- MalAPI.io — https://malapi.io
- Outflank blog — https://outflank.nl/blog
- SpecterOps blog — https://posts.specterops.io
- MDSec — https://www.mdsec.co.uk/category/blog/
