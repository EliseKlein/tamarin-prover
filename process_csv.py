import csv
import subprocess
import os

data_file_csv = 'csv/data_test.csv'
final_file_csv = 'csv/final.csv'
timeout = "10s" # 4h pour le script final ?
  
def modif_csv(label):  
    with open(data_file_csv,mode="r") as csvfile:
        with open(final_file_csv,mode="a") as finalfile:
            reader = csv.reader(csvfile,delimiter=';')
            writer = csv.writer(finalfile,delimiter=";")
            
            for row in reader:
                if row[0] != "0":
                    new_row = row.copy()
                    new_row.append(label)
                    
                    if "ProtoFact Linear" in row[5]:
                        new_row[5] = "ProtoFact Linear"
                    if "ProtoFact Persistent" in row[5]:
                        new_row[5] = "ProtoFact Persistent"
                    
                    writer.writerow(new_row)
            
            csvfile.close()
            finalfile.close()

command = "timeout " + timeout + " tamarin-prover running.spthy --prove --stop-on-trace=NONE"          
code_retour = subprocess.call(command, shell=True)

if code_retour == 0:
    modif_csv("0")
else:
    modif_csv("1")
os.remove(data_file_csv)