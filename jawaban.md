# JAWABAN TES TEKNIS DEVOPS

### 1. Penjelasan singkat tentang *DevOps*
   Berdasarkan apa yang pernah saya baca dari sebuah artikel, ***DevOps*** adalah sebuah posisi/jabatan dalam tim pengembangan perangkat lunak (*software development*) yang bertugas untuk menjembatani antara *System administrator* yang berkutat pada server dan jaringan dan *developer* yang berkutat pada *coding*

### 2. Komponen utama *DevOps*
|Komponen|Penjelasan|
|-|-|
|Continuous Integration|Sebuah metodologi pengembangan perangkat lunak yang bersifat berkesinambungan secara terus menerus, dengan melakukan pembaruan terintegrasi pada bagian/fitur dari sebuah *software*|
|Continuous Development|Proses pengembangan produk secara terus menerus tanpa henti dan akan menumbuhkan fungsi/fitur baru agar produk menjadi lebih baik (stabil, fitur bertambah, dll.)|
|Continuous Testing|Langkah yang harus dilakukan secara otomatis untuk menguji pembaruan, apabila ada perubahan/pembaruan terhadap fungsi/fitur sebelum diintegrasikan ke dalam produk|
|Automated Delivery|Sebuah proses yang dijalankan secara otomatis untuk melakukan pembaruan produk jika suatu fungsi/fitur lolos uji testing|
|Configuration Management|Pengelolaan konfigurasi dari sebuah produk yang meliputi API *encryption*, *password*, *certificate*, dll.|
|Regular Integration|Proses untuk mengimplementasikan fungsi/fitur ke dalam sebuah produk|
|Automated Monitoring|Proses untuk melihat laju pengembangan sebuah produk dan kestabilan dalam menjalankan tiap-tiap fungsi/fitur yang telah terintegrasi|
|Infrastructure as Code|Sebuah praktek untuk menyederhanakan konfigurasi dari banyak fungsi/fitur yang membutuhkan *dedicated device/server* ke dalam bentuk kode agar proses pengembangan perangkat lunak (produk) menjadi lebih efisien|

### 3. IaaS, PaaS, dan Saas
|Service <br/> (as a Service)|Penjelasan|Contoh|
|-|-|-|
|**IaaS** <br/> (Infrastructure) |Layanan *cloud* yang terdiri dari komputasi dan dapat diubah (dikembangkan) kebutuhan spesifikasinya. Umumnya **IaaS** berupa banyak *node* (VM/docker) yang saling bekerja sama secara otomatis berdasarkan konfigurasi yang telah ditentukan|GCP, AWS, Azure|
|**PaaS** <br/> (Platform) |Layanan *cloud* yang umum digunakan untuk pengembangan *software* atau layanan berbasis *serverless* dengan memanfaatkan teknologi virtualisasi/kontainer|AWS Lambda, Google App Engine|
|**SaaS** <br/> (Software) |Layanan *cloud* yang berupa *software* tanpa melakukan *maintenance* karena semuanya telah dikelola (*managed*) oleh pihak penyedia layanan. umumnya ditujukan untuk *end user*.|Github, Figma, Canva|

### 4. Penjelasan singkat
||||
|-|-|-|
|**a**|Git|Perintah untuk mengelola history source code dalam sebuah repositry|
|**b**|Jenkins dan Gitlab CI|Digunakan untuk melakukan otomasi dalam proses software development|
|**c**|SonarQube dan Selenium|Digunakan untuk melakukan otomasi pengetesan sebuah produk yang berbasis web|
|**d**|Ansible dan Puppet|Digunakan untuk melakukan otomasi infrastruktur yang digunakan dalam software development|
|**e**|Grafana dan ElasticSearch|Digunakan untuk monitoring node yang digunaka dalam software development|
|**f**|Docker|Software untuk membangun dan menjalankan aplikasi yang terisolasi, lengkap beserta library dan sistem operasinya, namun menggunakan kernel yang digunakan oleh sistem host, atau umum disebut dengan kontainer|

### 5. Kerja sama antar *tools*
Perintah git digunakan untuk membuat repository project dengan perintah `git init . -y`. Setelah itu menjalankan server Jenkins untuk menginisiasi CI project dengan membuat pipeline dalam bentuk `jenkinsfile`. Lalu membuat node dengan menggunakan teknologi kontainer dalam bentuk `Dockerfile` atau `docker-compose.yml`. Kemudian node-node yang telah dibuat dapat dioperasikan menggunakan Ansible dengan file `inventory` yang berekstensi `ini` / `yaml`. Kontainer yang telah dijalankan dapat dimonitor menggunakan Grafana, lalu kemudian dapat dilakukan testing dengan Selenium.

### 6. Bash script untuk otomasi
### --- File terlampir

### 7. .gitlab-ci.yml
```yaml
stages:
  - build
  - test
  - deploy

default:
  image: node

build-job:
  stage: build
  script:
    - npm install
    - npm run build
  artifacts:
    paths:
      - "build/"

lint-markdown:
  stage: test
  dependencies: []
  script:
    - npm install markdownlint-cli2 --global
    - markdownlint-cli2 -v
    - markdownlint-cli2 "blog/**/*.md" "docs/**/*.md"
  allow_failure: true

test-html:
  stage: test
  dependencies:
    - build-job
  script:
    - npm install --save-dev htmlhint
    - npx htmlhint --version
    - npx htmlhint build/

pages:
  stage: deploy
  image: busybox
  dependencies:
    - build-job
  script:
    - mv build/ public/
  artifacts:
    paths:
      - "public/"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

```
### 8. 
```
pipeline {
    agent any
    
    stages {
        stage('Run Script') {
            steps {
                chmod +x no8.sh
                sh 'no8.sh'
            }
        }
    }
}

```

### 9. Script Ansible
```yaml
---
- name: Install Nginx dan PHP dengan virtual host
  hosts: all
  become: yes
  vars:
    nginx_php_packages:
      Ubuntu: ["nginx", "php-fpm", "php-cli", "php-mbstring", "php-xml"]
      CentOS: ["nginx", "php", "php-cli", "php-mbstring", "php-xml"]

  tasks:
    - name: Install Nginx and PHP
      package:
        name: "{{ nginx_php_packages[ansible_distribution] }}"
        state: present
      loop_control:
        loop_var: pkg
      when: nginx_php_packages[ansible_distribution] is defined

    - name: Nginx service is enabled and started
      service:
        name: nginx
        state: started
        enabled: yes

    - name: PHP-FPM service is enabled and started
      service:
        name: php{{ item }}
        state: started
        enabled: yes
      loop:
        - fpm
        - fpm7.4
        - php-fpm
        - php7-fpm
        - php-fpm7.4
      when: ansible_distribution == "Ubuntu"

    - name: PHP-FPM service is enabled and started
      service:
        name: php-fpm
        state: started
        enabled: yes
      when: ansible_distribution == "CentOS"

    - name: Create index.php file
      copy:
        content: "<?php phpinfo(); ?>"
        dest: /var/www/html/index.php
      notify:
        - Restart PHP-FPM

    - name: Configure virtual host
      template:
        src: virtualhost.conf.j2
        dest: /etc/nginx/sites-available/default
      notify:
        - Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted

    - name: Restart PHP-FPM
      service:
        name: php{{ item }}
        state: restarted
      loop:
        - fpm
        - fpm7.4
        - php-fpm
        - php7-fpm
        - php-fpm7.4
      when: ansible_distribution == "Ubuntu"

    - name: Restart PHP-FPM (CentOS)
      service:
        name: php-fpm
        state: restarted
      when: ansible_distribution == "CentOS"

```
