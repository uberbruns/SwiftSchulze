# SwiftSchulze

## Install

### Requirements

* `brew`
* `mint` (installable via `brew install mint`)

### Installation

```
mint install uberbruns/SwiftSchulze
```

## Usage

```
Tool for calculating the winner of an election by letting voters cast their vote in form of a ranked list of candidates.

Usage: schulze
  -r,--ranking <Ranking>:
      A comma separated ranking of candidates casted by one voter. Repeat this option for every participant.
  -f,--format <Format>:
      The output format ('plain' or 'json').
  -i,--stdin:
      Takes a list of votes from standard input. Every line should contain a comma separated ranking.
  -p,--path <Path>:
      Use this option to provide a path to a file containing the casted rankings. Every line should contain the candidates ranked by one voter seperated via comma.
  -d,--directory <Directory>:
      Use this option to provide a directory containing .txt files. Every file should contain the candidates ranked by one voter. One candidate per line.
  -h,--help:
      Prints this help page.
```

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.
