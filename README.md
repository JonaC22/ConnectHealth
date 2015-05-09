# ConnectHealt

### Instalación por primera vez

#### Ubuntu

- Instalar rvm https://rvm.io/

	` gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 `

	` \curl -sSL https://get.rvm.io | bash -s stable `

- Instalar ruby 2.2.2 (es la ultima version estable)

	` rvm install 2.2.2 `

- Instalar rubygems
	- https://rubygems.org/pages/download
- Instalar bundler

	` gem install bundler `

- Instalar pg (si no tira error cuando se arma el bundle, primero instalar Postgresql)

	` sudo apt-get install libpq-dev `

	` gem install pg -v '0.17.1' `

- Clonar repositorio

	` git clone https://github.com/JonaC22/ConnectHealth.git `

- Instalar Heroku

	` wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh `

- Instalar gemas

	` cd ConnectHealth/ `

	` bundle install `

- Instalar nodejs

	` sudo apt-get install nodejs `

- Correr app en localhost

	` foreman start `
