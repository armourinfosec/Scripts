#!/usr/bin/env python3
import argparse
import subprocess
import sys
import os

def run_command(command, cwd=None):
    """
    Executes a shell command and prints its output in real-time.
    Args:
        command (str): The command to execute.
        cwd (str, optional): The working directory to execute the command in.
    """
    print(f"Running command: {command}")
    process = subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        cwd=cwd
    )
    # Print stdout in real-time
    for line in process.stdout:
        sys.stdout.write(line)
        sys.stdout.flush()
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        error_output = process.stderr.read()
        print(f"Error occurred:\n{error_output}", file=sys.stderr)
    print(f"Command completed with exit code {process.returncode}\n")

def filter_output(input_file, output_file, jq_filter):
    """
    Filters JSON output using jq and saves the result to a file.
    Args:
        input_file (str): Path to the input JSON file.
        output_file (str): Path to save the filtered output.
        jq_filter (str): The jq filter to apply.
    """
    print(f"Filtering output for {input_file} with filter '{jq_filter}'...")
    command = f"jq -r '{jq_filter}' {input_file}"
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            capture_output=True,
            text=True
        )
        filtered_data = result.stdout
    except subprocess.CalledProcessError as e:
        print(f"jq command failed: {e.stderr}", file=sys.stderr)
        return

    # Filter out lines that end with a colon
    clean_data = '\n'.join(line for line in filtered_data.splitlines() if not line.endswith(':'))
    
    with open(output_file, 'w') as f:
        f.write(clean_data)
    print(f"Filtering completed: {output_file}\n")

def main():
    parser = argparse.ArgumentParser(description="Run various network and web security scans.")
    parser.add_argument('-t', '--targetip', required=True, help='Target IP address')
    parser.add_argument('-o', '--outputdir', required=True, help='Output directory')

    args = parser.parse_args()

    ip = args.targetip
    output_dir = args.outputdir

    # Create the output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    print(f"Output directory set to: {output_dir}\n")

    # Use the directory name as the filename prefix
    prefix = os.path.basename(os.path.normpath(output_dir))

    # Run Nmap all ports scan
    print(f"Running Nmap all ports scan on {ip}...")
    nmap_all_ports_scan_cmd = f"nmap -v -p- {ip} -oA {prefix}-all-ports-scan"
    run_command(nmap_all_ports_scan_cmd, cwd=output_dir)

    # Extract open ports
    nmap_output_file = f"{prefix}-all-ports-scan.nmap"
    open_ports_list_file = f"{prefix}-open-ports-list.txt"
    print(f"Extracting open ports from {nmap_output_file}...")
    extract_ports_cmd = f"grep open {nmap_output_file} | cut -d '/' -f 1 | tr '\\n' ',' > {open_ports_list_file}"
    run_command(extract_ports_cmd, cwd=output_dir)

    # Read open ports
    try:
        with open(os.path.join(output_dir, open_ports_list_file), 'r') as f:
            open_ports = f.read().strip().rstrip(',')
    except FileNotFoundError:
        print(f"Open ports list file not found: {open_ports_list_file}", file=sys.stderr)
        sys.exit(1)

    if open_ports:
        print(f"Open ports found: {open_ports}\n")

        # Run Nmap server and version detection
        print("Running Nmap server and version detection on open ports...")
        nmap_scan_cmd = f"nmap -v -sT -sV -sC -A -O -p {open_ports} {ip} -oA {prefix}-nmap-version-scan"
        run_command(nmap_scan_cmd, cwd=output_dir)

        # Aggregate open ports for httpx
        host_open_ports_file = f"{prefix}-host-open-ports.txt"
        with open(os.path.join(output_dir, host_open_ports_file), 'w') as f:
            for port in open_ports.split(','):
                f.write(f"{ip}:{port}\n")
        print(f"Host open ports saved to {host_open_ports_file}\n")

        # Run httpx
        print("Running httpx on open ports...")
        httpx_output_file = f"{prefix}-httpx-output.json"
        httpx_cmd = f"httpx -sc -probe -method -hash -title -server -td -l {host_open_ports_file} -json -silent > {httpx_output_file}"
        run_command(httpx_cmd, cwd=output_dir)

        # Filter web URLs
        filtered_web_urls_file = f"{prefix}-filtered-web-urls.txt"
        filter_output(os.path.join(output_dir, httpx_output_file), os.path.join(output_dir, filtered_web_urls_file), "select(.failed == false) | .url")

        # Process each URL in filtered_web_urls_file
        try:
            with open(os.path.join(output_dir, filtered_web_urls_file), 'r') as f:
                urls = [line.strip() for line in f if line.strip()]
        except FileNotFoundError:
            print(f"Filtered web URLs file not found: {filtered_web_urls_file}", file=sys.stderr)
            urls = []

        for i, url in enumerate(urls, start=1):
            print(f"Processing URL {i}/{len(urls)}: {url}")

            # Run dirsearch without wordlist
            dirsearch_output = f"{prefix}-dirsearch-u{i}.txt"
            dirsearch_cmd = f"dirsearch -u {url} -o {dirsearch_output} -q"
            run_command(dirsearch_cmd, cwd=output_dir)

            # Run dirsearch with wordlist
            dirsearch_wordlist_output = f"{prefix}-dirsearch-u{i}-wordlist.txt"
            wordlist_path = "/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt"
            if not os.path.isfile(wordlist_path):
                print(f"Wordlist not found: {wordlist_path}", file=sys.stderr)
            else:
                dirsearch_wordlist_cmd = f"dirsearch -u {url} -w {wordlist_path} -o {dirsearch_wordlist_output} -q"
                run_command(dirsearch_wordlist_cmd, cwd=output_dir)

            # Run WhatWeb
            whatweb_output = f"{prefix}-whatweb-{i}.txt"
            whatweb_cmd = f"whatweb {url} --color=never > {whatweb_output}"
            run_command(whatweb_cmd, cwd=output_dir)

        # Run additional scans: Nikto and Nuclei
        print("Running Nikto and Nuclei scans on target IP...")
        nikto_output_file = f"{prefix}-nikto-output.txt"
        nikto_cmd = f"nikto -host {ip} -output {nikto_output_file}"
        run_command(nikto_cmd, cwd=output_dir)

        nuclei_output_file = f"{prefix}-nuclei-output.txt"
        nuclei_cmd = f"nuclei -silent -u {ip} -o {nuclei_output_file}"
        run_command(nuclei_cmd, cwd=output_dir)

    else:
        print("No open ports found.", file=sys.stderr)

if __name__ == "__main__":
    main()
