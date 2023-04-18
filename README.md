# Inserting Zacks Stocks Data Into IBM Cloudant Database

IBM Cloudant Database is used for storing large amounts of data. As IBM Cloudant is offering 1GB of free Database Storage, inserting information from zacks would make it easier to access.



# How to approach:
---

Step 1:
Make a database in sqlite3 and import information.

To make a database in sqlite3 first sqlite3 has to be installed using the following command:
Linux:
```
sudo apt install sqlite3
```

After this create a new database in sqlite3, I will be naming my database test.db



![image](https://user-images.githubusercontent.com/124895858/232708836-1421ecf3-84f8-46f5-902f-94140c9911ee.png)



After creating a database insert the information using my other repository Zacks Stocks.

Step 2:
Finding stocks that have different ranks.

After a few days of using a cron job to get the information into the sqlite3 database then we can use the following program to find stocks that have different ranks:

```
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
```

replace test.db with your database name and output to a file using ">". 




Step 3:
Creating a json file using a cat command:


Using the following cat command we can take the output from diffrank.sh and use vi to make small adjustments to put it into the cloudant database:

```
cat y | awk -F "|" '{print " { \n \"Date\":\"" $1 "\", \n \"Symbol\":\"" $2 "\", \n \"Name\":\"" $3     "\", \n \"Price\":\"" $4 "\", \n \"Rank\":\"" $5 "\" \n },"}'
```


Replace y with the filename you gave to the output of diffrank



Step 4:
Uploading to cloudant.

The final step is to upload the data to cloudant. This can be done by creating an account on cloudant here:  https://cloud.ibm.com/login

After creating an account search for cloudant and choose the first one:


![image](https://user-images.githubusercontent.com/124895858/232711771-04aaa32f-6eb6-4e4f-800b-ca507aa6fa09.png)


from here you should have a page looking like this:


![image](https://user-images.githubusercontent.com/124895858/232711996-eddf2d3e-ea57-498d-a2b0-5762a118a321.png)



After that choose "Service Credentials":


![image](https://user-images.githubusercontent.com/124895858/232712209-11eaab7f-a4b2-41f5-9f63-5fc8c1fa3712.png)


From here Click on "New Credential"


![image](https://user-images.githubusercontent.com/124895858/232712318-49a2939a-721c-4ef1-bdf1-aee6f4964990.png)



After getting a Credential Name the credential and then click on the arrow:


![image](https://user-images.githubusercontent.com/124895858/232712465-bb8f2033-d2c9-4070-bcba-d79a79cfaf60.png)



Copy the url given below on the page:


![image](https://user-images.githubusercontent.com/124895858/232712693-9f9c9eea-5d5f-41ce-9e0b-2eb88bc332ec.png)



When done go back to terminal and make an enviorment variable using the following command:

```
export URL=https://username:password@host
```

Create a command called "acurl" using this command:

```
alias acurl="curl -sgH 'Content-type: application/json'"
```

Then navigate we have to create a database before adding the information. To do this we use the Database webpage. To do this go back to your IBM webpage and press the "Launch Dashboard" button:



![image](https://user-images.githubusercontent.com/124895858/232714377-615c95e1-6b59-4492-ba6b-d64ffc3b7ed8.png)



Create a Database and Name it:


![image](https://user-images.githubusercontent.com/124895858/232714556-fa6a8847-d3ba-4714-aaaa-44ebe7508217.png)


Finally to import the information we using this command replacing database_name with your database name and data.json with your json file:


```
acurl -X POST -d@data.json $URL/database_name/_bulk_docs
```


Congratulations! You have successfully imported your stock data from https://zacks.com into IBM's Cloudant Database!
