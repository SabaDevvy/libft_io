/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_printf_utils.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gsabatin <gsabatin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/12/17 17:09:39 by gsabatin          #+#    #+#             */
/*   Updated: 2025/03/05 14:10:49 by gsabatin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/libft_printf.h"
#include <unistd.h>

void	ft_init_flags(t_flags *flags)
{
	flags->minus = 0;
	flags->zero = 0;
	flags->width = 0;
	flags->precision = -1;
	flags->hash = 0;
	flags->plus = 0;
	flags->space = 0;
}

int	ft_num_len(unsigned long n, int base_len)
{
	int	len;

	len = 0;
	if (n == 0)
		return (len + 1);
	while (n)
	{
		n /= base_len;
		len++;
	}
	return (len);
}

int	ft_pad(int width, char c)
{
	int	count;

	count = 0;
	while (width-- > 0)
		count += write(1, &c, 1);
	return (count);
}

int	ft_print_sign(unsigned long num, t_flags *flags, int is_unsigned, \
		char *base)
{
	if (flags -> hash && ft_strncmp(HEX, base, ft_strlen(HEX)) == 0 && num)
		return (write(1, "0x", 2));
	else if (flags -> hash && ft_strncmp(HEX_CAP, base, \
				ft_strlen(HEX_CAP)) == 0 && num)
		return (write(1, "0X", 2));
	else if (!is_unsigned && (int)num < 0)
		return (write(1, "-", 1));
	else if (!is_unsigned && flags -> plus)
		return (write(1, "+", 1));
	else if (!is_unsigned && flags -> space)
		return (write(1, " ", 1));
	return (0);
}

int	ft_get_min_width(unsigned long num, int len, t_flags *flags, \
		int is_unsigned)
{
	int	total;

	total = len;
	if (flags -> precision > total)
		total = flags -> precision;
	if ((!is_unsigned && (int)num < 0) || flags -> plus || flags -> space)
		total++;
	return (total);
}
