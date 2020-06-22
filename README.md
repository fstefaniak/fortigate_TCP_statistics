# fortigate_sessions_statistics

## introduction

Sripts are developed to analyze and made statistics on sessions from fortigate logs files. I use them to define needs on a loadbalancing project but you can use it for a lot of others reasons.

They were test on logs from Fortigate 1500D with firmware version 5.6

## setup

Copy scripts or clone this repository with git where you want. If you have large files, try to have good reading speed to reduce execution time.

## requirements

you need to have read access to the fortigates logs files

for the get_stats_duration_sessions.sh script you will need ministat package

## what difference between the two scripts ?

- get_stats_nb_sessions.sh

this one will give you the number of different session (based on sessionid) associate with the targeting IP per log file.

- get_stats_duration_sessions.sh

this second will give statistics on total duration associate with the targeting IP per log file based session which stop. it will create a tempory data.txt to store infos while executing. But to create statistics he will need at least match 3 closed session in the log for the targetting IP or it will be ignored.

if you have enough traffic with not only long session, you must have similary but not same results on the Number of session per log file because some can be active in the log but not be closed in it so the second script will not count it.

Note for loadbalancing analyse: if you target a loadbalancing IP by the fortigate cluster, it's seem that you can have a results multiply by 2 get_stats_nb_sessions.sh then get_stats_duration_sessions.sh if the IP is associate with a zone in fortigate configuration. But it's not apply when the IP is not associate with a specific zone.

## parameters

|   # |  Description |
| ------------ | ------------ |
|  1 |  path for logs (ex: "/mnt/path/to/fortigate/log/folder" )  |
|  2 |  IPv4 target  (ex: 192.168.10.2) |
| 3, 4 ... | [optionnal] if you want add others target IPv4 |

## Fortigate logs files and execution times

I haven't use time discrimition on this script because the folder of fortigate logs contains files split by hours.

The execution time depend of the logs total size. If you have large size, you can use "nohup" package to avoid session interruption if you working in ssh.

## results

the results are store in .json file. You can easely use it in excel or libre office calc with a convertion website to csv if you made graphics.

## development

scripts were created by Fabien Stéfaniak in is work of Network and Systems Administrator at the university of Angers.

the code is validated by [shellcheck](http://www.shellcheck.net "shellcheck")

[![Université d'Angers](http://marque.univ-angers.fr/_resources/Logos/_GENERIQUE/HORIZONTAL/ECRAN/PNG/ua_h_couleur_ecran.png "Université d'Angers")](https://www.univ-angers.fr "Université d'Angers")
