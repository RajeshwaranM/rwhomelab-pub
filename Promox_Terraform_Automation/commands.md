.\packer.exe validate -var-file=".\credentials.pkr.hcl" ".\ubuntu.pkr.hcl"
.\packer.exe build -var-file=".\credentials.pkr.hcl" ".\ubuntu.pkr.hcl"
