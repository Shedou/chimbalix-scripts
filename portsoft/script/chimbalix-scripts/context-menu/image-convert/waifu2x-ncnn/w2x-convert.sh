#!/usr/bin/env bash
# Script version 1.0
# LICENSE for this script is at the end of this file
# Work with https://github.com/nihui/waifu2x-ncnn-vulkan

# Font styles
# Usage: "${B}Bold Text${N}"
B=$(tput bold); N=$(tput sgr0)

Mod="$1"; shift; # arg 1
Strong="$1"; shift; # arg 2
Model="$1"; shift; # arg 3

Files=("$@")

# Variables
BasePath="/portsoft/x86_64/waifu2x-ncnn"
Exec="$BasePath/waifu2x-ncnn-vulkan"
ErrorFiles=""; GoodFiles=""; pause="0"
OutMod=""; OutStrong=""; OutModel=""; TQ=""

# Processing args

if [ "$Model" != "default" ]; then
	OutModel="$BasePath/$Model"
else
	OutModel="$BasePath/models-cunet"
fi

# CheckName function
function CheckName {
	local FileName="$1"; local OutFileName="$FileName.png"; local time="$(date +%s)"; local tx="${time:6}"
	if [ -e "$OutFileName" ]; then OutFileName="$FileName-new.png"
		if [ -e "$OutFileName" ]; then OutFileName="$FileName-new-$tx.png"; fi
	fi
	echo "$OutFileName"
}

CPU_mode=0
CPU=""

# DeNoise
if [ "$Mod" == "Noise" ]; then
	TQ="-N$Strong"
	echo -e "Try to convert. \n"
	for i in "${!Files[@]}"; do
		CurrentFile="${Files[$i]}"
		OutputFileName="${CurrentFile%.*}"
		OutName="$OutputFileName$TQ"
		
		# check if the output file exists
		OutName="$(CheckName "$OutName")"
		
		FileNameWithoutPath="$(basename "$OutName")"
		
		# Run prepared command
		if $Exec $CPU -i "$CurrentFile" -o "$OutName" -m "$OutModel" -n $Strong -s 1; then echo "$FileNameWithoutPath: Finished."
		else
			ErrorFiles="${ErrorFiles}\n $OutName"; pause="1";
			echo -e "\n ----------------------- \n -- TRY CPU ONLY MODE -- "
			CPU="-g -1"
			if $Exec $CPU -i "$CurrentFile" -o "$OutName" -m "$OutModel" -n $Strong -s 1; then echo "$FileNameWithoutPath: Finished."
			else
				echo -e "\n WARNING! ERROR! Pause..."
				read pause
			fi
		fi
	done
fi

# Scale
if [ "$Mod" == "Scale" ]; then
	TQ="-S$Strong"
	echo -e "Try to convert. \n"
	for i in "${!Files[@]}"; do
		CurrentFile="${Files[$i]}"
		OutputFileName="${CurrentFile%.*}"
		OutName="$OutputFileName$TQ"
		
		# check if the output file exists
		OutName="$(CheckName "$OutName")"
		
		FileNameWithoutPath="$(basename "$OutName")"
		
		# Run prepared command
		if $Exec $CPU -i "$CurrentFile" -o "$OutName" -m "$OutModel" -n 0 -s $Strong; then echo "$FileNameWithoutPath: Finished."
		else
			ErrorFiles="${ErrorFiles}\n $OutName"; pause="1";
			echo -e "\n ----------------------- \n -- TRY CPU ONLY MODE -- "
			CPU="-g -1"
			if $Exec $CPU -i "$CurrentFile" -o "$OutName" -m "$OutModel" -n $Strong -s 1; then echo "$FileNameWithoutPath: Finished."
			else
				echo -e "\n WARNING! ERROR! Pause..."
				read pause
			fi
		fi
	done
fi

if [ "$pause" == "1" ]; then
	echo -e "\

-= WARNING =-
$ErrorFiles"
	read pause
fi

# MIT License
#
# Copyright (c) 2024 Chimbal
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
