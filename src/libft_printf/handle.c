/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   handle.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gsabatin <gsabatin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/12/16 17:07:12 by gsabatin          #+#    #+#             */
/*   Updated: 2025/03/18 07:59:24 by gsabatin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../includes/libft_printf.h"
#include <stdarg.h>
#include <unistd.h>

static int	ft_handle_char(int c, t_flags *flags)
{
	int	count;

	count = 0;
	if (!flags -> minus && flags -> width > 1)
		count += ft_pad(flags -> width - 1, ' ');
	count += write(1, &c, 1);
	if (flags -> minus && flags -> width > 1)
		count += ft_pad(flags -> width - 1, ' ');
	return (count);
}

static int	ft_handle_str(char *str, t_flags *flags)
{
	int	count;
	int	len;

	count = 0;
	if (!str)
		str = "(null)";
	len = ft_strlen(str);
	if (flags -> precision >= 0 && flags -> precision < len)
		len = flags -> precision;
	if (!flags -> minus && flags -> width > len)
		count += ft_pad(flags -> width - len, ' ');
	count += write(1, str, len);
	if (flags -> minus && flags -> width > len)
		count += ft_pad(flags -> width - len, ' ');
	return (count);
}

static int	ft_handle_ptr(void *ptr, t_flags *flags)
{
	int					count;
	int					len;
	unsigned long int	addr;

	count = 0;
	addr = (unsigned long int)ptr;
	if (!ptr)
		return (write(1, "(nil)", 5));
	len = ft_num_len(addr, ft_strlen(HEX)) + 2;
	if (!flags -> minus && flags -> width > len)
		count += ft_pad(flags -> width - len, ' ');
	count += write(1, "0x", 2);
	count += ft_putnbr_base(addr, HEX);
	if (flags -> minus && flags -> width > len)
		count += ft_pad(flags -> width - len, ' ');
	return (count);
}

static int	ft_handle_num(unsigned long num, t_flags *flags, int is_unsigned, \
		char *base)
{
	int					count;
	int					num_len;
	int					min_width;
	unsigned long		n;

	count = 0;
	n = num;
	if (!is_unsigned && (int)num < 0)
		n = -(unsigned long)((int)num);
	num_len = ft_num_len(n, ft_strlen(base));
	min_width = ft_get_min_width(num, num_len, flags, is_unsigned);
	if (!flags -> minus && !flags -> zero && flags -> width > min_width)
		count += ft_pad(flags -> width - min_width, ' ');
	count += ft_print_sign(num, flags, is_unsigned, base);
	if (flags -> zero && flags -> width > min_width)
		count += ft_pad(flags -> width - min_width, '0');
	if (flags -> precision > num_len)
		count += ft_pad(flags -> precision - num_len, '0');
	if (!(num == 0 && flags -> precision == 0))
		count += ft_putnbr_base(n, base);
	if (flags -> minus && flags -> width > min_width)
		count += ft_pad(flags -> width - min_width, ' ');
	return (count);
}

void	ft_format_handler(const char **format, va_list *ap, \
		t_flags *flags, int *count)
{
	if (**format == 'c')
		*count += ft_handle_char(va_arg(*ap, int), flags);
	else if (**format == 's')
		*count += ft_handle_str(va_arg(*ap, char *), flags);
	else if (**format == 'p')
		*count += ft_handle_ptr(va_arg(*ap, void *), flags);
	else if (**format == 'd' || **format == 'i')
		*count += ft_handle_num(va_arg(*ap, int), flags, 0, DEC);
	else if (**format == 'u')
		*count += ft_handle_num(va_arg(*ap, unsigned int), flags, 1, DEC);
	else if (**format == 'x')
		*count += ft_handle_num(va_arg(*ap, unsigned int), flags, 1, HEX);
	else if (**format == 'X')
		*count += ft_handle_num(va_arg(*ap, unsigned int), flags, 1, HEX_CAP);
	else if (**format == '%')
		*count += ft_handle_char('%', flags);
}
