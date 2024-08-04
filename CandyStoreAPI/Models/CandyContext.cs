using CandyStoreAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace CandyStoreAPI.Models;

public class CandyContext : DbContext
{
    public CandyContext(DbContextOptions<CandyContext> options)
        : base(options)
    {
    }

    public DbSet<Candy> Candy { get; set; } = null!;
}