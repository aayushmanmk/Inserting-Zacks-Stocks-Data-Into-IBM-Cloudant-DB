#!/bin/bash
dateno=$(sqlite3 test.db "select count(distinct Date) from ZACKS_STOCKS;")
stocklist=`cat snp.txt`
for stock in $stocklist
do
ranks=$(sqlite3 test.db "select rank from ZACKS_STOCKS WHERE SYMBOL=\"$stock\";")

IFS=$'\n' read -d '' -ra lines_array <<< "$ranks"

all_lines_match=true

# Compare lines
for (( i=1; i<${#lines_array[@]}; i++ ))
do
  if [ "${lines_array[i]}" != "${lines_array[0]}" ]; then
    all_lines_match=false
    break
  fi
done

distinct_lines=($(printf '%s\n' "${lines_array[@]}" | sort -u))

# Print all lines if they do not match
if ! $all_lines_match; then

array_length=${#distinct_lines[@]}

# Loop through each element in the array
for ((i=0; i<$array_length; i++))
do
  # If it is the first element, start the sentence with $
  if [ $i -eq 0 ]
  then
    sentence="$stock went from"
  else
    sentence+=" ${distinct_lines[$(($i-1))]} to ${distinct_lines[$i]} to"
  fi
done

newsentence="${sentence::-3}"

# Print the final sentence
echo $newsentence
  echo "start"
  sqlite3 test.db "select * from ZACKS_STOCKS WHERE SYMBOL=\"$stock\" ORDER BY DATE;"
  echo "end"
  stockcount=$((stockcount+1))


fi

done

