/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   libft_printf.h                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gsabatin <gsabatin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/12/14 22:35:14 by gsabatin          #+#    #+#             */
/*   Updated: 2025/03/17 19:06:51 by gsabatin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef LIBFT_PRINTF_H
# define LIBFT_PRINTF_H

# include <stdarg.h>

# include "libft.h"

# define DEC		"0123456789"
# define HEX		"0123456789abcdef"
# define HEX_CAP	"0123456789ABCDEF"

/**
 * @struct
 * @brief Struct in which flags will be included.
 *
 * %[flags][width][.precision][length]specifier;
 *
 * (.) : Precision: minimum number of digits to appear for integers, \
 * the number of digits after the decimal point for floating-point values, \
 * the maximum number of characters to be printed for strings.
 *
 * (#) flag: The value should be converted to an “alternate form”.
 * No effect for d, i, n, p, s, and u.
 * x and X conversions, a non-zero result has the string ‘0x’ (or ‘0X’).
 *
 * (-) flag: converted value is to be left adjusted on the field boundary
 * overrides 0 if it is given.
 *
 * (' ') (space) flag: A blank should be left before a positive number.
 *
 * (+) flag:  A sign must always be placed before a number produced \
 * by a signed conversion.  A + overrides a space if both are used.
 *
 * (0) flag: 0 padding.
 * If a precision is given with a numeric conversion the 0 flag is ignored.
**/
typedef struct s_flags
{
	int	minus;
	int	zero;
	int	width;
	int	precision;
	int	hash;
	int	plus;
	int	space;
}	t_flags;

// Main functions
int		ft_printf(const char *format, ...);
void	ft_parse_flags(const char **format, t_flags *flags);
void	ft_format_handler(const char **format, va_list *ap, \
		t_flags *flags, int *count);

// Utils
void	ft_init_flags(t_flags *flags);
int		ft_pad(int width, char c);
int		ft_print_sign(unsigned long num, t_flags *flags, \
		int is_unsigned, char *base);
int		ft_get_min_width(unsigned long num, int len, \
		t_flags *flags, int is_unsigned);
int		ft_num_len(unsigned long n, int base_len);

// Putnumbers
int		ft_putnbr_base(unsigned long num, char *base);

#endif
