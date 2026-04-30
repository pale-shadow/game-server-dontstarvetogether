# Don't Starve Together - Dedicated Server

* To play on the Dont Starve Together server, start the game on Steam, then
  look for the server named &quot;wonderland&quot;
* Create a dedicated user for the game, such as `dst`.
  * make the repo clone the home directory of the new dst user.

![dst](https://github.com/devsecfranklin/game-server-dontstarvetogether/blob/main/images/dst-personajes.jpg)

## Get a Cluster Token

- [excellent information on dedicated servers](https://dontstarve.wiki.gg/wiki/Guides/Don%E2%80%99t_Starve_Together_Dedicated_Servers)
- [this is a good resource](https://github.com/mathielo/dst-dedicated-server/blob/main/docs/ClusterToken.md)

1. Visit the Klei site and choose Steam to login: [https://accounts.klei.com/login](https://accounts.klei.com/login)
2. Link your steam account to your Klei account.
3. Select the games link at the top, then click the "game servers" button on the dont starve together tile.
4. Now add a new server, or get the Cluster Token for an existing server.
5. Add the `CLUSTER_TOKEN` to the environment vars, or the `.envrc` file. DO not check this file into github.

## Install `direnv`

* We will use `direnv` to pick up the secret token from an environment variable.
  * [install direnv](https://direnv.net/docs/installation.html)

```sh
curl -sfL https://direnv.net/install.sh | bash 
eval "$(direnv hook bash)"
```

Now create a file called `.envrc` in this top level folder. The `CLUSTER_TOKEN`
line is mandatory!

```sh
export CLUSTER_TOKEN="pef-g^KU_QrGp3bke^uerRdBrRFyKING2q9zypelrosOjFYc1g="
export FYP_OPTIONS="-DFYP_CCACHE=ON"
export CXXFLAGS="-std=c++11"
```

## install game server files via steamcmd

- install `steamcmd` then run this command to install the server files

```sh
 steamcmd +login anonymous +app_update 343050 validate +quit
```

## Edit config files

* Edit the [files in the top level `./saves` directory](https://github.com/devsecfranklin/game-server-dontstarvetogether/tree/main/saves) 
  * These will be copied into place by the scripts later.
* There is [a new script](saves/gen_mod_override.sh) to generate the `saves/modoverrides.lua` file. 
  * It just got tedious recreating it by hand every time we wanted to test a new server side mod.

## Crontab Entry

You can cause the gamse server to update itself at a time when you should probably be sleeping.
Use the `crontab -e` command to add this line to your dst service user crontab:

`0 4 * * * /usr/games/steamcmd +login anonymous +app_update 343050 validate +quit`

## Run Scripts

Finally, these scripts set up the environment and start the game server. Be
sure to run them in this order.

```sh
./bin/bootstrap.sh
cd saves && ./gen_mod_override.sh && cd -
./bin/run_dedicated_server.sh
```

