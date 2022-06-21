#!/bin/bash

echo "debug:building .net"
# dotnet build "Templates/WebAPI/Devon4Net.Application.WebAPI/Devon4Net.Application.WebAPI.csproj" -c Release
dotnet build -c Release

echo "debug:publishing ... ${targetDirectory}"
# dotnet publish "Templates/WebAPI/Devon4Net.Application.WebAPI/Devon4Net.Application.WebAPI.csproj" -c Release -o "${targetDirectory}"
dotnet publish -c Release -o "${targetDirectory}"

