# Monotes

Monotes is a GitHub Issues commandline client.

## Installation

Add this line to your application's Gemfile:

    gem 'monotes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monotes

## Usage

### Login to GitHub

```bash
$ monotes login
Username: <your usename>
Password: <Password>
```

### Login with Two-Factor Authentication

```bash
$ monotes login
Username: <your usename>
Password: <Password>
Your 2FA token: <Token>
```

### Download issues for repository

```bash
$ monotes download 'schultyy/monotes'
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/monotes/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

