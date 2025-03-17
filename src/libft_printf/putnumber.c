/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   putnumber.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: gsabatin <gsabatin@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/12/17 04:45:50 by gsabatin          #+#    #+#             */
/*   Updated: 2025/03/05 14:11:20 by gsabatin         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/libft_printf.h"
#include <stdlib.h>
#include <unistd.h>

int	ft_putnbr_base(unsigned long n, char *base)
{
	int				chars_written;
	unsigned int	base_len;

	base_len = ft_strlen(base);
	if (n >= base_len)
		chars_written = ft_putnbr_base(n / base_len, base);
	else
		chars_written = 0;
	return (chars_written + write(1, &base[n % base_len], 1));
}
