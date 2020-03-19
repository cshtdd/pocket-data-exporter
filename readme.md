# Pocket Exporter  

Pocket can export user data in a single html.  
This is not great when trying to migrate the data to another organized service.  

# Execution  

1- Create a pocket app  
2- Create an environment file  

```bash
cat <<EOF >> .env
CONSUMER_KEY=your-app-consumer-key
DEBUG=false
EOF
```

3- Run the app  

```bash
dotenv thin --threaded start
```

4- Follow the instructions. Download the json file  

5- Get a list of articles per tag  

```bash
ruby ./utils/parser.rb ~/Downloads/pocket_data.json
```

# Docs  
- https://getpocket.com/developer/docs/v3/retrieve
- https://getpocket.com/connected_applications
