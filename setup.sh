eval 'docker-compose up -d db redis'
eval 'docker-compose build app sidekiq'
eval 'docker-compose run app rake db:create'
eval 'docker-compose run app rake db:migrate'
eval 'docker-compose up -d app sidekiq'