# OverTheWire VM Lab

This repo contains local VM setups that recreate OverTheWire wargame environments (currently Behemoth and Vortex). Each game lives in its own directory with its own template, launcher, levels, and MOTD.

See https://www.overthewire.org for the real environment.

## Differences to the real environment

We do our best to configure the VM similarly to the real wargame environment, but have not actually verified every parameter. Most kernel level security mitigations are turned off (aslr, cpu vuln mitigations, page table isolation, etc).

Users homedirs are writable.

For vortex we use an older ubuntu base image, due to a change in how the kernel deals with an empty argv, which otherwise breaks vortex13.

## Repository Structure

- `<game>/lima-<game>-x64.yaml`
  - Main Lima template and provisioning script for that game.
- `<game>/start-lima-<game>-x64.sh`
  - Wrapper that injects the correct absolute host mount path at runtime.
- `<game>/levels/`
  - Place game binaries here on the host; they are copied into the corresponding path in the VM during provisioning.
- `<game>/assets/`
  - Shared provisioning assets (for example MOTD text and systemd unit templates).

Current game directory:

- `behemoth/`
- `vortex/`

## Where To Place Levels

Put binaries into the game directory’s `levels/` folder (for example `behemoth/levels/`). The setup scripts will still work with missing levels.

For Behemoth specifically:

- expected names include `behemoth0`, `behemoth1`, ..., `behemoth8`
- special case: `behemoth6_reader`

On provisioning, files from `behemoth/levels/` are copied to `/behemoth` and ownership/modes are applied.

For Vortex specifically:

- expected names include `vortex0`, `vortex1`, ..., `vortex26`
- Level 14, 15 and 23 have passwords hardcoded in their respective files, so the passwords the lima provisioning script sets are not accurate. You'll need to overwrite them manually if you want the actual user passwords to be correct.
- Level 20 has important files in the homedirectory, copy those files to `vortex/host-files/home/vortex20 for the provisioning script to set them up correctly.

On provisioning, files from `vortex/levels/` are copied to `/vortex` and ownership/modes are applied.

## Users And Passwords (Behemoth)

- Users `behemoth0` through `behemoth9` are created.
- Passwords are generated and stored in `/etc/behemoth_pass/behemothX`.
- Each password file is readable only by that target user (`behemothX:behemothX`, `440`).

## Users And Passwords (Vortex)

- Users `vortex0` through `vortex27` are created.
- Passwords are generated and stored in `/etc/vortex_pass/vortexX`.
- Each password file is readable only by that target user (`vortexX:vortexX`, `440`).

## Start / Recreate (Behemoth)

From repo root:

```bash
./behemoth/start-lima-behemoth-x64.sh
```

## Start / Recreate (Vortex)

From repo root:

```bash
./vortex/start-lima-vortex-x64.sh
```

To start playing:

```bash
limactl shell --workdir=/behemoth lima-behemoth-x64
sudo su - behemoth0
/behemoth/behemoth0

limactl shell --workdir=/vortex lima-vortex-x64
sudo su - vortex1
/vortex/vortex1
```

If you need a clean rebuild:

```bash
limactl stop lima-behemoth-x64
limactl delete -f lima-behemoth-x64
./behemoth/start-lima-behemoth-x64.sh
```

## AI agents setup

One of the goals of the projects was setting up an environment where we can test recent AI agents to see how they perform. See [Lima agents example](https://lima-vm.io/docs/examples/ai/) for generic instructions.

Codex:
```bash
limactl shell lima-behemoth-x64 -- sudo snap install node --classic
limactl shell lima-behemoth-x64 -- sudo npm install -g @openai/codex
```

Login to any levels user and run `codex`, follow the instructions to authenticate.
