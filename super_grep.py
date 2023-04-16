import os
import sys
import argparse
import time
import re
from pathlib import Path

def show_help():
    help_text = '''
Usage:
    code_scraper.py [-p <Path>] -s <String> [-o <OutputFile>] [-t <SleepDurationInSeconds>] [--ignore-case] [-h]

Options:
    -p, --path <Path>                      : The path to search for files (default is the current path).
    -s, --string <String>                  : The string to search for in the files (mandatory).
    -o, --output <OutputFile>              : The output file to save the results (optional, results will be printed to console if not provided).
    -t, --sleep <SleepDurationInSeconds>   : The number of seconds to sleep between code blocks (default is 2).
    --ignore-case                          : Perform a case-insensitive search for the target string.
    -h, --help                             : Show this help message.

Examples:
    python code_scraper.py -s "svg"
    python code_scraper.py -p "/path/to/your/folder" -s "svg" -o "output.txt" -t 3 --ignore-case
    '''
    print(help_text)

parser = argparse.ArgumentParser(add_help=False)
parser.add_argument('-p', '--path', default='', type=str)
parser.add_argument('-s', '--string', default='', type=str)
parser.add_argument('-o', '--output', default='', type=str)
parser.add_argument('-t', '--sleep', default=2, type=int)
parser.add_argument('--ignore-case', action='store_true')
parser.add_argument('-h', '--help', action='store_true')

args = parser.parse_args()

if args.help or not args.string:
    if not args.string:
        print("Error: The --string parameter is mandatory.\n")
    show_help()
    sys.exit()

search_path = args.path or os.getcwd()
string_to_search = args.string
output_file = args.output
sleep_duration = args.sleep
ignore_case = args.ignore_case

already_printed_code_blocks = set()
output_data = []

for root, _, files in os.walk(search_path):
    for file in files:
        file_path = os.path.join(root, file)
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()

        for i, line in enumerate(lines):
            if ignore_case:
                search_result = string_to_search.lower() in line.lower()
            else:
                search_result = string_to_search in line

            if search_result:
                start_index = i - 1
                while start_index >= 0 and not re.match(r'^\s*$', lines[start_index]):
                    start_index -= 1

                end_index = i + 1
                while end_index < len(lines) and not re.match(r'^\s*$', lines[end_index]):
                    end_index += 1

                code_block = lines[start_index + 1:end_index]
                code_block_str = ''.join(code_block)

                if code_block_str not in already_printed_code_blocks:
                    output = f"Found '{string_to_search}' in file: {file_path}\nLine number: {i + 1}\nCode block:\n{code_block_str}\n"
                    output_data.append(output)

                    if not output_file:
                        print(output)
                        time.sleep(sleep_duration)

                    already_printed_code_blocks.add(code_block_str)

if output_file:
    with open(output_file, 'w') as f:
        f.writelines(output_data)