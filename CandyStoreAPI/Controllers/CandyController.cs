using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CandyStoreAPI.Models;

namespace CandyStoreAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CandyController : ControllerBase
    {
        private readonly CandyContext _context;

        public CandyController(CandyContext context)
        {
            _context = context;
        }

        // GET: api/Candy
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Candy>>> GetCandy()
        {
            return await _context.Candy.ToListAsync();
        }

        // GET: api/Candy/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Candy>> GetCandy(long id)
        {
            var candy = await _context.Candy.FindAsync(id);

            if (candy == null)
            {
                return NotFound();
            }

            return candy;
        }

        // PUT: api/Candy/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutTodoItem(long id, Candy candy)
        {
            if (id != candy.Id)
            {
                return BadRequest();
            }

            _context.Entry(candy).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!CandyExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/Candy
        [HttpPost]
        public async Task<ActionResult<Candy>> AddCandy(Candy candy)
        {
            _context.Candy.Add(candy);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetCandy), new { id = candy.Id }, candy);
        }

        // DELETE: api/Candy/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> SellCandy(long id)
        {
            var candy = await _context.Candy.FindAsync(id);
            if (candy == null)
            {
                return NotFound();
            }

            _context.Candy.Remove(candy);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool CandyExists(long id)
        {
            return _context.Candy.Any(e => e.Id == id);
        }
    }
}
