// install_docker.rs
// Purpose: Automated, clean installation and configuration of Docker on Kali Linux.
// Run with: rustc install_docker.rs && ./install_docker

use std::process::Command;
use std::io::{self, Write};

fn run_command(command: &str, args: &[&str]) -> Result<(), String> {
    print!("> {} {}\n", command, args.join(" "));
    io::stdout().flush().unwrap();
    let output = Command::new(command)
        .args(args)
        .output()
        .expect(&format!("failed to execute command: {}", command));

    if !output.status.success() {
        eprintln!("Error: {}", String::from_utf8_lossy(&output.stderr));
        return Err(String::from_utf8_lossy(&output.stderr).to_string());
    }
    Ok(())
}

fn main() -> Result<(), String> {
    println!("🐳 Installing Docker Engine on Kali Linux...");

    // 1. Remove any conflicting packages
    println!("\n[1/7] Removing old Docker packages...");
    let _ = run_command("sudo", &["apt-get", "remove", "-y", "docker", "docker-engine", "docker.io", "containerd", "runc"]);

    // 2. Install dependencies for adding a new repository over HTTPS
    println!("\n[2/7] Installing dependencies...");
    run_command("sudo", &["apt-get", "install", "-y", "ca-certificates", "curl", "gnupg", "lsb-release"])?;

    // 3. Add Docker's official GPG key
    println!("\n[3/7] Adding Docker's GPG key...");
    run_command("sudo", &["install", "-m", "0755", "-d", "/etc/apt/keyrings"])?;
    run_command("curl", &["-fsSL", "https://download.docker.com/linux/debian/gpg", "-o", "/etc/apt/keyrings/docker.asc"])?;
    run_command("sudo", &["chmod", "a+r", "/etc/apt/keyrings/docker.asc"])?;

    // 4. Set up the stable Docker repository for Debian Bookworm
    println!("\n[4/7] Setting up Docker repository...");
    let repo_entry = "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable";
    run_command("echo", &[repo_entry, "|", "sudo", "tee", "/etc/apt/sources.list.d/docker.list", ">", "/dev/null"])?;

    // 5. Update package index and install Docker Engine
    println!("\n[5/7] Installing Docker Engine and plugins...");
    run_command("sudo", &["apt-get", "update"])?;
    run_command("sudo", &["apt-get", "install", "-y", "docker-ce", "docker-ce-cli", "containerd.io", "docker-buildx-plugin", "docker-compose-plugin"])?;

    // 6. Start and enable the Docker service
    println!("\n[6/7] Starting and enabling Docker service...");
    run_command("sudo", &["systemctl", "start", "docker"])?;
    run_command("sudo", &["systemctl", "enable", "docker"])?;

    // 7. Add the current user to the 'docker' group
    println!("\n[7/7] Adding current user to the 'docker' group...");
    run_command("sudo", &["usermod", "-aG", "docker", "$USER"])?;
    println!("   ⚠️  You will need to log out and back in for group changes to take effect.");
    println!("   To test immediately in a new shell, run: newgrp docker");

    // Verification
    println!("\n✅ Docker installation complete.");
    println!("   Verify with: docker run hello-world");
    Ok(())
}
