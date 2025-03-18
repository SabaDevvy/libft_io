/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_flags.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gsabatin <gsabatin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/12/18 10:00:00 by gsabatin          #+#    #+#             */
/*   Updated: 2025/03/18 07:59:36 by gsabatin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/libft_printf.h"

static int	ft_is_flag(char c)
{
	return (c == '-' || c == '0' || c == '.' || c == '#' || \
		c == ' ' || c == '+' || ft_isdigit(c));
}

static void	ft_handle_precision(const char **format, t_flags *flags)
{
	flags->zero = 0;
	flags -> precision *= 0;
	(*format)++;
	while (ft_isdigit(**format))
	{
		flags->precision = flags->precision * 10 + (**format - '0');
		(*format)++;
	}
	(*format)--;
}

static void	ft_handle_width(const char **format, t_flags *flags)
{
	if (flags -> width != 0)
		flags -> width *= 0;
	if (**format == '0' && !flags->width && flags->precision == -1)
		flags->zero = 1;
	else
	{
		while (ft_isdigit(**format))
		{
			flags->width = flags->width * 10 + (**format - '0');
			(*format)++;
		}
		(*format)--;
	}
}

static void	ft_handle_flags(char c, t_flags *flags)
{
	if (c == '-')
	{
		flags->minus = 1;
		flags->zero = 0;
	}
	else if (c == '+')
	{
		flags->plus = 1;
		flags->space = 0;
	}
	else if (c == ' ' && !flags->plus)
		flags->space = 1;
	else if (c == '#')
		flags->hash = 1;
}

void	ft_parse_flags(const char **format, t_flags *flags)
{
	while (ft_is_flag(**format))
	{
		if (**format == '.')
			ft_handle_precision(format, flags);
		else if (ft_isdigit(**format))
			ft_handle_width(format, flags);
		else
			ft_handle_flags(**format, flags);
		(*format)++;
	}
}
