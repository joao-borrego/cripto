# Users and Passwords

| **Subject**                 | **User**      | **Password**     |  **Observations**                                     |
| -------------               |:-------------:| :------------:   |  :---:                                                 |
| IDP Database                | root          |    ''            |Grants permission to shibboleth and simplesaml tables |
| IDP Database                | user          |   db_pass        |Grants permission to shibboleth and simplesaml tables |
| IDP Backchannel PKCS12      | -             | back_pass        |                                                       |
| IDP Cookie Encryption Key   | -             | crypt_pass       |                                                       |
| SP simplesaml               | admin         | pikachuichooseyou|Grants permission to simplesaml admin page [1]  |                                                     |
| IDP DB simplesaml users     | user1         | user1pass        |AES_ENCRYPT KEY = 'key'                                              

[1] http://sp.group9.csc.com/simplesaml/admin/
