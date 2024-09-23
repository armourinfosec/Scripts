<h1 align="center">Box Scanning</h1>

This script performs a comprehensive security scan on a specified target IP address. It integrates various tools to conduct network scans, web application assessments, and vulnerability checks.

## Prerequisites

Ensure the following tools are installed on your system:

- `nmap`: For network scanning.
- `jq`: For processing JSON data.
- `httpx`: For probing web services.
- `dirsearch`: For directory brute-forcing.
- `whatweb`: For web technology fingerprinting.
- `nikto`: For web server vulnerability scanning.
- `nuclei`: For vulnerability scanning using templates.

Here’s an improved version of your `README.md` installation instructions:

---

## Installation

Follow the steps below to download and set up the script:

1. **Download the Python Script:**

   Download the `box-scanning.py` script from the repository:

   ```sh
   wget https://raw.githubusercontent.com/InfoSecWarrior/Offensive-Pentesting-Scripts/main/Box-Scanning/box-scanning.py
   ```

2. **Download the Requirements File:**

   Get the `requirements.txt` file to install the necessary dependencies:

   ```sh
   wget https://raw.githubusercontent.com/InfoSecWarrior/Offensive-Pentesting-Scripts/main/Box-Scanning/requirements.txt
   ```

3. **Install Dependencies:**

   Install the required Python libraries by running the following command:

   ```sh
   pip3 install -r requirements.txt
   ```

## Usage

Run the script from the command line with the following syntax:

```sh
python box-scanning.py -t <target_ip> -o <output_directory_prefix>
```

### Arguments

- `-t`, `--targetip`: **Required**. The IP address of the target to be scanned.
- `-o`, `--outputdir`: **Required**. The script generates the prefix for the output directory.

### Example

To scan the target IP `192.168.1.1` and save the results with the prefix `scan_results`, you would use:

```sh
python box-scanning.py -t 192.168.1.1 -o scan_results
```

## Script Workflow

1. **Network Scan**:
   - Performs an `nmap` scan on all ports and saves the output.
   - Extracts open ports and performs a detailed `nmap` scan on them.

2. **Web Services Detection**:
   - Uses `httpx` to probe open ports for web services.
   - Filters the results and performs directory scans using `dirsearch` and web technology analysis using `whatweb`.

3. **Vulnerability Scanning**:
   - Executes `nikto` and `nuclei` scans for additional vulnerabilities.

## Output Files

The script generates several output files based on the provided prefix:

- `-all-ports-scan.nmap`: Output of the full port scan.
- `-open-ports-list.txt`: List of open ports.
- `-nmap-version-scan.nmap`: Version scan of open ports.
- `-httpx-output.json`: Output from `httpx`.
- `-filtered-web-urls.txt`: Filtered URLs from the `httpx` output.
- `-dirsearch-u*.txt`: Directory scan results for each discovered URL.
- `-whatweb-*.txt`: Web technology information for each discovered URL.
- `-nikto-output.txt`: Output from `nikto`.
- `-nuclei-output.txt`: Output from `nuclei`.