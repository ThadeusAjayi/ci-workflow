#!/bin/bash

npm install

pm2 start index.js --name expressapp --watch