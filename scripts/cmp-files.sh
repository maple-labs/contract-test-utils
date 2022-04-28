#!/usr/bin/env bash
set -e

while getopts a:b: flag
do
    case "${flag}" in
        a) a=${OPTARG};;
        b) b=${OPTARG};;
    esac
done

cmp $a $b
result=$(cmp $a $b)

SUB=differ

if [[ "$result" == *"$SUB"* ]]; then
  exit(1)
fi
