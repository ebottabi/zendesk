with 
ticket_summary as 
(
	select
		*, date_trunc('week', ticket_date)::date as ticket_week,
		date_trunc('week', solved_date)::date as solved_week
	from ac_yevgeniy.zendesk_ticket_summary
),

new_tickets as
(
	select ticket_week as week, count(*) as num_new
	from ticket_summary
	group by ticket_week
),

solved_tickets as
(
	select solved_week as week, count(*) as num_solved
	from ticket_summary
	group by solved_week
)

select
	week,
	sum(num_new) over(order by week rows unbounded preceding) as cum_new,
	sum(num_solved) over(order by week rows unbounded preceding) as cum_solved,
	sum(backlog) over(order by week rows unbounded preceding) as cum_backlog
from
(
	select new_tickets.week, num_new, num_solved, (num_new-num_solved) as backlog
	from new_tickets
	left outer join solved_tickets
		on new_tickets.week = solved_tickets.week
	order by new_tickets.week
)
order by week

