Docker container for maintenance of LetsEncrypt certificates
==========================================================
Uses EFF's certbot to create and manage LetsEncrypt's certificates with an
acme-dns-auth hook. It is not intended to be used as a background container.
Instead it runs certbot commands from the docker-run command line parameters.

When run with no parameters, it will report the registered account and certificates and then run the help command.

Links
-----
- [LetsEncrypt: https://letsencrypt.org/](https://letsencrypt.org/)
- [EFF Certbot: https://certbot.eff.org/](https://certbot.eff.org/) 
- [Joona Hoikkala's ACME Dns Certbot hook: https://github.com/joohoi/acme-dns-certbot-joohoi](https://github.com/joohoi/acme-dns-certbot-joohoi)

Notes
-----
- The container should be run with a volume `/certificates`. It will store working files and generated certificates
  here. See `/certificates/live` for the domains and their created certificates.  
- As the private keys are stored here, it should be made secure.  
- Without parameters, the container run will report the account and existing live certificates.  
- You will have to use the **Register** command to register your account and email address first before creating
  any certificates.  
- See **Commands** below for available commands to supply as parameters on the container run.  
- Only wild card Common Name certificates are currently supported - Eg: `*.example.com`
- DNS is used for the challenge and so creating a certificate requires you to add a **`CNAME`** record to the DNS
  for the domain of the certificate. The line to add will be output at time of certificate creation.

TODO
----
- Allow creation of specific Common Name certificates rather than the default wildcard 
- Support auto renewal - possibly using healthcheck to check near expiry and then renew.  

HowTo
-----
- Commands:
  <pre>
  Show       Show Account and Certificate Details
  Register   Register Account with LetsEncrypt
               Example: Register myemail@example.com
  UnRegister Unregister Account
  Create     Create Certificate with given domain,
               Example: Create example.com
               (Will prompt you to add DNS Record and hit return)
  Renew      Renew expired or close to expiry certificates
               (Can provide optional Certificate Name)
  Delete     Delete Certificate
               Example: Delete example.com
  Certbot    Run certbot with your own commands
  Shell      Will run a bash shell in the container
  Help       This help
  </pre>
- Volumes:  
  - **`/certificates`**  
    Where certbot working files, account details and generated certificates will be stored.
- Run user:  
  The default is to run the container as root - it is advisable to run as an alternative userid/groupid. Eg:  
  `docker run --user=1001:1001` ...  
- Example Runs  
    - Register your email address and create a new account  
      <pre>
      docker run \
          -v $HOME/cert-store:/certificates \
          docker-certbot:latest \
          Register JoeBloggs@example.com
      </pre>
    - Create a certificate for a domain (Eg: _example.com_):  
      This will create new certs in `$HOME/cert-store/live/example.com/`:  
      - **`fullchain.pem`**: The full certificate chain to install in your application;  
      - **`privkey.pem`**: The private key for the certificate - this is created with mode 600 and should be
        similarly protected when installed in your application.  

      It will provide you with a **`CNAME`** record to add to the certificate domain's DNS server
      and prompt you to hit return when the **`CNAME`** record has been added and propagated out. As
      such, the docker run should include **`-it`** to attach a terminal to the container run.
      <pre>
      docker run \
          -it \
          --user=1001:1001 \
          -v $HOME/cert-store:/certificates \
          docker-certbot:latest \
          create example.com
      </pre>

<!--
vim: ai wm=2 sw=2 ts=2 expandtab
-->
