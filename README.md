## Appfigures Extension for MoneyMoney


## What is this?

Use this extension to see your app sales in MoneyMoney.  
You will need an [Appfigures account](https://appfigures.com).


## Usage

- Put the file `Appfigures.lua` into your [MoneyMoney Extensions folder.](https://moneymoney-app.com/extensions/)
- Register an API key in your Appfigures account [here](https://appfigures.com/developers/keys).
- Set permissions for the API key to:  
    + `Read: Account Info`
    + `Read: Product Meta Data`
    + `Read: Private Data`


## Authentication

When MoneyMoney asks you for your **password**, please fill in *both* your account password (the web login password) *and* the client API key; **concatenated without a space.**


### Example: 

If your password is:  
`1supersecr3tp@ssword`

…and your **client** key is:  
`0ae4362ecf898cd9c3156730b5c0cac0` 

…then enter this in MoneyMoney’s password field:  
`1supersecr3tp@ssword0ae4362ecf898cd9c3156730b5c0cac0`


## Signing

MoneyMoney extensions must be signed by the creators of MoneyMoney, which is the case for release versions here on GitHub.
If you you use pre-release versions or if you make any modifications to the script yourself, you’ll need to allow unsigned scripts to run.

[Read the MoneyMoney extensions documentation](https://moneymoney-app.com/extensions/) to find out how it works.


### License

MIT License; see the `LICENSE` file in this repository.
