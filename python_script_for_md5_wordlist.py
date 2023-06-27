import hashlib

# Specify the file path
file_path = input('path/to/input_file.txt: ')

# Open the input file in read mode
with open(file_path, 'r') as f:
    lines = f.readlines()

# Open the output file in write mode
with open('result_md5.txt', 'w') as f1:
    # Iterate over each line in the input file
    for line in lines:
        # Encode the line using the md5 hash function
        encoded_line = line.encode('utf-8')
        md5_hash = hashlib.md5(encoded_line).hexdigest()

        # Write the MD5 hash to the output file
        f1.write(md5_hash + '\n')

# Close the files (not required due to the use of 'with' statement)
# f1.close()
# f.close()

