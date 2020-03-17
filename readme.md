# Pocket Exporter  

Pocket can export user data in a single html.  
This is not great when trying to migrate the data to another organized service.  

# Execution  

1- Create a pocket app  
2- Create an environment file  

```bash
cat <<EOF >> .env
CONSUMER_KEY=your-app-consumer-key
EOF
```

3- Run the app  

```bash
dotenv ruby main.rb
```