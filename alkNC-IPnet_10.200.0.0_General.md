alkNC - Data network
==================
## Private network - 10.200.0.0
```bash
10.200.0.0/16 # Address block "General organization network"
  10.200.0.0/19 #Address block "AWS Site"
    10.200.0.0/21 #Address Block "Main VPC"
      10.200.0.0/22 #Address Block "Not Operation"
        10.200.0.0/23 #Address block "Infrastructure"
          10.200.0.0/24 #Address block "Systems managed by Internals"
            10.200.0.0/26 #Address block for "AZ A"
            10.200.64.0/26 #Address block for "AZ B"
            10.200.128.0/26 #Address block for "AZ C (reserverd)"
            10.200.0.192/26 #Address block "AWS controlled IP assignments"
              10.200.0.192/28 #Address block for "AZ A"
              10.200.0.208/28 #Address block for "AZ B"
              10.200.0.224/28 #Address block for "AZ C (Reserverd)"
          10.200.1.0/24 #Address block "Reserved"
        10.200.2.0/23 #Address block "Reserved"
      10.200.4.0/22 #Address Block "Operation"
        10.200.4.0/24 #Segmento de red "Operación DEV"
          10.200.4.0/26 #Address block for "AZ A"
            10.200.4.8/30 #Backend on DEV stage in AZ A
          10.200.4.64/26 #Address block for "AZ B"
            10.200.72.8/30 #Backend on DEV stage in AZ B
          10.200.4.128/26 #Address block for "AZ C (Reserverd)"
          10.200.4.192/26 #Address block "AWS controlled IP assignments"
            10.200.4.192/28 #Address block for "AZ A"
            10.200.4.208/28 #Address block for "AZ B"
            10.200.4.224/28 #Address block for "AZ C (Reserverd)""
        10.200.5.0/24 #Segmento de red "Operación STG"
          10.200.5.0/26#Address block for "AZ A"
          10.200.5.64/26 #Address block for "AZ B"
          10.200.5.128/26 #Address block for "AZ C (Reserverd)"
          10.200.5.192/26 #Address block "AWS controlled IP assignments"
            10.200.5.192/28 #Address block for "AZ A"
            10.200.5.208/28 #Address block for "AZ B"
            10.200.5.224/28 #Address block for "AZ C (Reserverd)"
        10.200.6.0/24 #Segmento de red "Operación PRO"
          10.200.6.0/26 #Address block for "AZ A"
          10.200.6.64/26 #Address block for "AZ B"
          10.200.6.128/26 #Segmento de red "Zona C (Reservada)"
          10.200.6.192/26 #Address block "AWS controlled IP assignments"
            10.200.6.192/28 #Address block for "AZ A"
            10.200.6.208/28 #Address block for "AZ B"
            10.200.6.224/28 #Address block for "AZ C (Reserverd)"
        10.200.7.0/24 #Address Block "Demarcation"
```

