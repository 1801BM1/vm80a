@echo off
del *.bak /s /q
rd org\syn\de0\db /S /Q
rd org\syn\de0\incremental_db /S /Q
rd org\syn\de0\output_files /S /Q
rd org\syn\de1\db /S /Q
rd org\syn\de1\incremental_db /S /Q
rd org\syn\de1\output_files /S /Q
rd org\syn\de2-115\db /S /Q
rd org\syn\de2-115\incremental_db /S /Q
rd org\syn\de2-115\output_files /S /Q
rd org\syn\ax309\work /S /Q
rd wbc\syn\de0\db /S /Q
rd wbc\syn\de0\incremental_db /S /Q
rd wbc\syn\de0\output_files /S /Q
for /r ".\org" %%1 in (*.v) do tst\tools\atxt32 %%1 %%1 -s3 -f
for /r ".\wbc" %%1 in (*.v) do tst\tools\atxt32 %%1 %%1 -s3 -f
@echo on
