title: Add Namecheap DDNS on DSM
date: 2017-08-04
tags: [DSM, DDNS]

---
1.SSH into your Synology NAS
2.Type:
```
sudo vi /usr/syno/bin/ddns/namecheap.php
```
<!-- more -->
3a.For paste insert mode type :set paste
3b.Press i
4a.Paste the following:
```
#!/usr/bin/php -d open_basedir=/usr/syno/bin/ddns
<?php

if ($argc !== 5) {
    echo 'badparam';
    exit();
}

$account = (string)$argv[1];
$pwd = (string)$argv[2];
$hostname = (string)$argv[3];
$ip = (string)$argv[4];

// check the hostname contains '.'
if (strpos($hostname, '.') === false) {
    echo 'badparam';
    exit();
}

// only for IPv4 format
if (!filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
    echo "badparam";
    exit();
}

//$array = explode('.', $hostname);
//$domain = implode('.', array_slice($array, 1));
//$hostname = implode('.', array_slice($array, 0, 1));

$url = 'https://dynamicdns.park-your-domain.com/update?host='.$account.'&domain='.$hostname.'&password='.$pwd.'&ip='.$ip;
echo $url;

$req = curl_init();
curl_setopt($req, CURLOPT_URL, $url);
curl_setopt($req, CURLOPT_RETURNTRANSFER, true);
$res = curl_exec($req);
curl_close($req);

/*

Success response:

<?xml version="1.0"?>
  <interface-response>
    <Command>SETDNSHOST</Command>
    <Language>eng</Language>
    <IP>%ip-address%</IP>
    <ErrCount>%error-count%</ErrCount>
    <ResponseCount>%response-count%</ResponseCount>
    <Done>true</Done>
    <debug><![CDATA[]]></debug>
</interface-response>

%ip-address% = IP address
%error-count% = 0
%response-count% = 0

Failure response:

<?xml version="1.0"?>
  <interface-response>
    <Command>SETDNSHOST</Command>
    <Language>eng</Language>
    <ErrCount>%error-count%</ErrCount>
    <errors>
      <Err1>%error-message%</Err1>
    </errors>
    <ResponseCount>%response-count%</ResponseCount>
    <responses>
      <response>
        <ResponseNumber>%response-number%</ResponseNumber>
        <ResponseString>%response-message%</ResponseString>
      </response>
    </responses>
    <Done>true</Done>
    <debug><![CDATA[]]></debug>
</interface-response>

%error-count% = 1
%error-message% = Error message
%response-count% = 1
%response-number% = Code for response message
%response-message% = Response message (similar to %error-message%)

*/

$xml = new SimpleXMLElement($res);
if ($xml->ErrCount > 0) {
    $error = $xml->errors[0]->Err1;
    if (strcmp($error, "Domain name not found") === 0) {
        echo "nohost";
    } elseif (strcmp($error, "Passwords do not match") === 0) {
        echo "badauth";
    } elseif (strcmp($error, "No Records updated. A record not Found;") === 0) {
        echo "nohost";
    } else {
        echo "911 [".$error."]";
    }
} else {
    echo "good";
}
```

***Make sure when you copy the first script that there aren't any extra # inserted into VI. I had this issue and had to remove them from each line.
4b.Press ESC and then type :set nopaste
5.Save and quit by pressing CTRL+C then :wq
6.Run:
```
sudo chmod 755 /usr/syno/bin/ddns/namecheap.php
```
7.Run:
```
sudo vi /etc.defaults/ddns_provider.conf
```
8.For insert mode press i
9.Go to the bottom and paste the following:
```
[Namecheap]
        modulepath=/usr/syno/bin/ddns/namecheap.php
        queryurl=https://dynamicdns.park-your-domain.com/
```
10.Save and quit by pressing CTRL+C then :wq
11.In the DSM web interface, open the DDNS menu
12.Click Add
Hostname: yourDomain.tld
Username/Email: @ 
Password: nameCheap DDNS password

Reference:[Site](https://forum.synology.com/enu/viewtopic.php?f=190&t=46711&p=446143#p446143)
