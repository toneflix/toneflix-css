#!/bin/bash
############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "This script requires that you have SASS installed to run."
   echo "Usage ./build.sh [input/dir] [output/dir] [-h|w]"
   echo
   echo "options:"
   echo "-h, --help           Display this help."
   echo "-h, --help-sass      Display the help for sass."
   echo "-w, --watch          Watch stylesheets and recompile when they change."
   echo
}

# Set default variable values
help="0"
params=""
ext="css"
input_file=$1
output_file=$2

# Colors
GREEN='\032[0;32m'
BLUE='\034[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  install_command="${NC}\nsudo apt install ruby-full build-essential rubygems\nsudo gem install sass"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  install_command="${NC}\nbrew install sass/sass/sass"
else
  install_command="${NC}npm install -g sass"
fi

# Check if SASS is installed
if ! command -v sass &> /dev/null
then
    echo -e "${RED}It seems you do not have sass installed. \nThis script requires that you have SASS installed to run.\nTo install sass run: ${install_command}"
    exit
fi

# Loop through $parameters and restructure
for opt in $@
do
  if [[ "$opt" == "--help" || "$opt" == "-h" ]]; then
    Help
    help="--$opt"
    exit 1
  elif [[ "$opt" == "--help-sass" ]]; then
    sass --help
    exit 1
  elif [[ "$opt" == "--watch" ]]; then
    params="$opt "
  fi

  if [[ "$opt" == "--min" ]]; then
    params="$params --style=compressed "
    ext="min.css"
  fi
done

# Get the path to this bash file
replace="/build.sh"
replace_with=""
curr_dir="${0/${replace}/${replace_with}}"

if [[ -n "$input_file" ]] && [[ "$input_file" != "--watch" ]] && [[ "$input_file" != "--min" ]]; then
  input_basename="/$(basename ${input_file})"

  echo $rename
  if [[ ! -d "${input_file/${input_basename}/${replace_with}}" ]]; then
    echo -e "\n${RED} Input path \"$input_file\" not found."
    exit 0
  fi
fi

if [[ -n "$output_file" ]] && [[ "$output_file" != "--watch" ]] && [[ "$output_file" != "--min" ]]; then
  output_basename="/$(basename ${output_file})"
  if [[ ! -d "${output_file/${output_basename}/${replace_with}}" ]]; then
    echo -e "\n${RED} Output path \"$output_file\" not found."
    exit 0
  else
    output_file="${output_file/${output_basename}/${replace_with}}${output_basename/css/${ext}}"
  fi
fi

# Run the sass command
if [[ "$help" == "0" ]]; then
  if [[ -n $input_file ]] && [[ -n $output_file ]]; then
    sass ${params}"${input_file}" "${output_file}/build/toneflix-utility.${ext}"
  else
    sass ${params}"${curr_dir}/src/index.scss" "${curr_dir}/build/toneflix-utility.${ext}"
  fi
fi
