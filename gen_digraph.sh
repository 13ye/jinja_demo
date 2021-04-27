#!/bin/bash
DIR=svgs
mkdir -p $DIR
dot -Tsvg  read.table.digraph -o $DIR/read.table.svg
dot -Tsvg  write.table.digraph -o $DIR/write.table.svg
rm read.table.digraph
rm write.table.digraph
