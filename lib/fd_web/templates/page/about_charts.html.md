# Charts

Charts are generated by [chartd.co](https://chartd.co) and cached for up to thirty minutes.

## Instance charts

    https://fediverse.network/:instance_domain/chart/:datasources.png
    https://fediverse.network/:instance_domain/chart/:datasources.svg

Parameters:

* `instance_domain`: the instance domain

## Params

* `datasources`: one or many datasources for the charts, comma separated:
  * `users`
  * `statuses`
  * `peers`
  * `users_new`
  * `statuses_new`
  * `peers_new`

  Up to five datasources can be used in a graph.

Optional parameters:

* `interval`: interval between datapoints, default to `hourly`
  * `5min`
  * `hourly`
  * `3h`
  * `weekly`
  * `monthly`
  * `90d`

* `limit`: number of datapoints

* `style`: apply a pre-defined chartd style
  * `default`: `?w=580&h=180&or=1&step=1&t=auto`
  * `sparkline`: `?w=50,h=16,or=1,ol=1,s0=222222&t=none`
  * `none`: no default style

* All of the styling parameters supported by [chartd.co](https://chartd.co):
  * `w` chart width,
  * `h` chart height,
  * `t` chart title,
    * `auto` to automatically generate a title
    * `none`
  * `ymin` and `xmin` x/y minimum,
  * `ymax` and `xmax` x/y maximum,
  * `hl` hilight last point (1 to turn on),
  * `ol` only left y-axis (1 to turn on),
  * `or` only right y-axis (1 to turn on),
  * `step` step chart (1 to turn on),
  * `s0..s5` and `f0..f5` stroke and fill colours for the various datasources (same ordering as the datasources ordering),
  * `tz` x axis timezone (IANA location name, Europe/Paris)

## Examples

* `/mastodon.social/chart/users.png?w=200&h=80`

  ![](/mastodon.social/chart/users.png?w=200&h=80)

* `/pawoo.net/users_new.png?w=200&h=80&t=none`

  ![](/pawoo.net/chart/users_new.png?w=200&h=80&t=none)

* `/pleroma.site/chart/statuses_new.png?f0=FFA500&s0=FF0000&step=0&t=pleroma.site%20activity&w=200&h=80`

  ![](/pleroma.site/chart/statuses_new.png?f0=FFA500&s0=FF0000&step=0&t=pleroma.site activity&w=200&h=80)

* `/fediverse.network/chart/statuses_new.png?style=sparkline`

  ![](/fediverse.network/chart/statuses_new.png?style=sparkline)




