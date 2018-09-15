# htaccess {file,line} syntax test

Testing a file for syntax errors;

```
$ ./htaccess-file-test.sh htaccess.test
```

Testing a line for syntax errors;

```
$ echo "RewriteRule from /to [R=301]" | ./htaccess-line-test.sh
```
