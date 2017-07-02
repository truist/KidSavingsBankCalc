#!/usr/bin/env perl

use strict;
use warnings;

use v5.10;

use List::Util qw(min max);

my $savings_bonus_base = 1;

my $savings_bonus_interest_amount = 0.25;
my $balance_interest_threshold_age_multiplier = 12;
my $balance_interest_threshold_drop = 0.01;

# set one or the other of these to 0
my $weekly_savings_percent = 1.0;
my $weekly_savings_amount = 0;

# set one or the other of these to 0
my $weekly_bonus_savings_percent = 1.0;
my $weekly_bonus_savings_amount = 0;

my $min_savings_bonus_threshold = 1;

sub main {
	my $weekly_earnings = 2;
	my $annual_earnings_increase_percent = 0.4;

	say(sprintf("%-3s" . ("%11s" x 5), qw(age end_earn sav_bal end_cash end_int subsidized)));

	my $savings_balance = 0;
	my $cash_balance = 0;
	my $subsidy_balance = 0;
	for (my $age = 5; $age < 18; $age++) {
		($savings_balance) = calc_year_end($savings_balance, 0, 0, $age, $weekly_earnings);

		$weekly_earnings *= (1 + $annual_earnings_increase_percent);
	}
}

sub calc_year_end {
	my ($savings_balance, $cash_balance, $subsidy_balance, $age, $weekly_earnings) = @_;

	my $final_interest = 0;
	my $final_cash = 0;
	foreach (1..52) {
		my $weekly_savings = $weekly_earnings * $weekly_savings_percent + $weekly_savings_amount;
		$savings_balance += $weekly_savings;
		if ($weekly_savings >= $min_savings_bonus_threshold) {
			#my $interest = int($savings_balance / $age) * $savings_bonus_interest_amount;
			my $interest = calc_interest($savings_balance, $age);
			my $bonus = $savings_bonus_base + $interest;
			$subsidy_balance += $bonus;

			my $bonus_saved = $bonus * $weekly_bonus_savings_percent + $weekly_bonus_savings_amount;
			$savings_balance += $bonus_saved;

			my $cash = ($weekly_earnings - $weekly_savings) + ($bonus - $bonus_saved);
			$cash_balance += $cash;

			$final_interest = $interest;
			$final_cash = $cash;
		}
	}
	say(sprintf("%3d" . ("%11.2f" x 5), $age, $weekly_earnings, $savings_balance, $final_cash, $final_interest, $subsidy_balance));
	return ($savings_balance, $cash_balance, $subsidy_balance);
}

sub calc_interest {
	my ($working_balance, $age) = @_;

	my $segment_size = $age * $balance_interest_threshold_age_multiplier;

	my $working_interest_rate = $savings_bonus_interest_amount;

	my $interest_payment = 0;
	while ($working_balance > 0) {
		my $segment_balance = min($working_balance, $segment_size);
		$working_balance -= $segment_balance;

		$interest_payment += int($segment_balance / $age) * $working_interest_rate;

		$working_interest_rate -= $balance_interest_threshold_drop;
		$working_interest_rate = max(0, $working_interest_rate);
	}

	return $interest_payment;
}

main() ? exit 0 : exit 1;

