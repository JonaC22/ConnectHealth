# ConnectHealt

### Endpoints

/pacientes

### Herramientas a utlizar

- Ruby 2.2.2
- MySQL 5.6.19
- Rails 4.1.8
- Neo4j 2.2.1

### Instalación por primera vez

#### Windows

- Instalar [ruby 2.2.2] (http://rubyinstaller.org/downloads/)

- Instalar [MySQL] (http://corlewsolutions.com/articles/article-23-how-to-install-mysql2-gem-on-windows-7)

    ` gem install mysql2 --platform="ruby" -- --with-mysql-dir="C:\Ruby22-x64\C-Connector" `

- Instalar RubyMine [Torrent MagnetLink](magnet:?xt=urn:btih:4becc6d64bb35eb6c59ebb6d106b0f8f180de6f9&dn=JetBrains+RubyMine+v6+3+3+Incl+KeyMaker-DVT&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Fexodus.desync.com%3A6969)

- Instalar DevKit [Guide](http://stackoverflow.com/questions/10694997/gem-install-json-v-1-7-3-gives-please-update-your-path-to-include-build-tools)
 [Download](http://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe)

- Instalar [OpenSSL] (https://github.com/hicknhack-software/rails-disco/wiki/Installing-puma-on-windows)

- Instalar puma  
	` gem install puma -v '2.9.1' -- --with-opt-dir=c:\Ruby22-x64/openssl `

- Instalar Heroku Toolbelt  

- Bajar config de heroku  

    ` heroku config:pull --overwrite --interactive `

#### Ubuntu

- Instalar [rvm](https://rvm.io/)

	` gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 `

	` \curl -sSL https://get.rvm.io | bash -s stable `

- Instalar ruby 2.2.2 (es la ultima version estable)

	` rvm install 2.2.2 `

- Instalar [rubygems] (https://rubygems.org/pages/download)

- Instalar bundler

	` gem install bundler `

- Clonar repositorio

	` git clone https://github.com/JonaC22/ConnectHealth.git `

- Instalar Heroku

	` wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh `

- Instalar nodejs

	` sudo apt-get install nodejs `

- Instalar gemas

	` cd ConnectHealth/ `

	` bundle install `

- Correr app en localhost

	` foreman start `

Ante cualquier error con las gemas, seguir indicaciones del log de errores (seguramente otros apt-get install)

### Para correr en Linux

- Una vez instalado, siempre repetir estos pasos

	` cd ConnectHealth/ `

	` bundle install `

- Correr app en localhost

	` foreman start `

#### Librerias

##### JS

- [Joint] (https://github.com/clientIO/joint)
- [Angular] (https://angularjs.org/)