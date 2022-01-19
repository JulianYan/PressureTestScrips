find . -iname *memory.txt > 1.txt
cat 1.txt | while read line; 
do
echo $line
python plotMemR.py $line
done
