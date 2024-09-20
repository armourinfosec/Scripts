#!/usr/bin/env python3
import argparse
import subprocess
import sys

def run_command(command):
    """Executes a shell command and prints its output in real-time."""
    print(f"Running command: {command}")
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    for line in process.stdout:
        sys.stdout.write(line)
        sys.stdout.flush()
    process.stdout.close()
    process.wait()
    if process.returncode != 0:
        error_output = process.stderr.read()
        print(f"Error occurred:\n{error_output}")
    print(f"Command completed with exit code {process.returncode}")

def filter_output(input_file, output_file, jq_filter):
    """Filters output using jq and saves to a file."""
    print(f"Filtering output for {input_file} with filter '{jq_filter}'...")
    command = f"jq -r '{jq_filter}' {input_file}"
    filtered_data = subprocess.run(command, shell=True, check=True, capture_output=True, text=True).stdout

    # Filter out URLs that end with a colon
    clean_data = '\n'.join(line for line in filtered_data.splitlines() if not line.endswith(':'))
    
    with open(output_file, 'w') as f:
        f.write(clean_data)
    print(f"Filtering completed: {output_file}")

def main():
    parser = argparse.ArgumentParser(description="Run various network and web security scans.")
    parser.add_argument('-t', '--targetip', required=True, help='Target IP address')
    parser.add_argument('-o', '--outputfilename', required=True, help='Output filename prefix')

    args = parser.parse_args()

    ip = args.targetip
    output_file = args.outputfilename

    # Run nmap all port scan
    print(f"Running nmap all port scan on {ip}...")
    nmap_all_ports_scan = f"nmap -v -p- {ip} -oA {output_file}-all-ports-scan"
    run_command(nmap_all_ports_scan)

    # Extract open ports
    print(f"Extracting open ports from {output_file}-all-ports-scan.nmap...")
    open_ports_command = f"grep open {output_file}-all-ports-scan.nmap | cut -d '/' -f 1 | tr '\\n' ',' > {output_file}-open-ports-list.txt"
    run_command(open_ports_command)

    # Run nmap for server and version detection
    with open(f"{output_file}-open-ports-list.txt") as f:
        open_ports = f.read().strip()
    
    if open_ports:
        print(f"Running nmap server and version detection on open ports...")
        nmap_scan = f"nmap -v -sT -sV -sC -A -O -p {open_ports} {ip} -oA {output_file}-nmap-scan"
        run_command(nmap_scan)

        # Aggregate open ports for httpx
        host_open_ports_file = f"{output_file}-host-open-ports.txt"
        with open(host_open_ports_file, 'w') as f:
            for port in open_ports.split(','):
                f.write(f"{ip}:{port}\n")

        # Run httpx
        print(f"Running httpx on {host_open_ports_file}...")
        httpx_command = f"httpx -sc -probe -method -hash -title -server -td -l {host_open_ports_file} -json -silent"
        httpx_output_file = f"{output_file}-httpx-output.json"
        run_command(f"{httpx_command} > {httpx_output_file}")

        # Filter web URLs
        filtered_web_urls_file = f"{output_file}-filtered-web-urls.txt"
        filter_output(httpx_output_file, filtered_web_urls_file, "select(.failed == false) | .url")

        # Process each URL in filtered-web-urls.txt
        with open(filtered_web_urls_file) as f:
            urls = f.readlines()

        for i, url in enumerate(urls, start=1):
            url = url.strip()
            print(f"Running directory scans on {url}...")
            dirsearch_command = f"dirsearch -u {url} -o {output_file}-dirsearch-u{i}.txt"
            run_command(dirsearch_command)
            dirsearch_wordlist_command = f"dirsearch -u {url} -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -o {output_file}-dirsearch-u{i}-wordlist.txt"
            run_command(dirsearch_wordlist_command)
            whatweb_command = f"whatweb {url} --color=never > {output_file}-whatweb-{i}.txt"
            run_command(whatweb_command)

        # Run additional scans
        print(f"Running Nikto and Nuclei scans on {ip}...")
        nikto_command = f"nikto -host {ip} -output {output_file}-nikto-output.txt"
        run_command(nikto_command)
        nuclei_command = f"nuclei -silent -u {ip} -o {output_file}-nuclei-output.txt"
        run_command(nuclei_command)

    else:
        print("No open ports found.")

if __name__ == "__main__":
    main()

