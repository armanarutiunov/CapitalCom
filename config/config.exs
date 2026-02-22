import Config

config :capital_com,
  req_options: [receive_timeout: 15_000]

config :capital_com_strategy,
  default_mode: :paper
