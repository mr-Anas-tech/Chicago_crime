select * from
{{ source('chicago_crime', 'crime') }}